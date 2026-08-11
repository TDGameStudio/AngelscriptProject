## Context

The initialized script surface currently receives Math functions from three independent naming mechanisms:

1. `Bind_FMath.cpp` selects `Math` or `FMath` from `UAngelscriptSettings::MathNamespace` and registers manual native functions in that namespace.
2. `UAngelscriptMathLibrary` declares `ScriptName="Math"`; an editor-only tail in `Bind_FMath.cpp` mutates that metadata to `FMath` when the compatibility setting selects it.
3. Unreal's `UKismetMathLibrary` declares `ScriptName="MathLibrary"`, and `FAngelscriptFunctionSignature::GetScriptNamespaceForClass()` currently accepts class `ScriptName` as the namespace for reflected static functions.

`UKismetMathLibrary` is not one uniform namespace surface. Functions whose `ScriptMethod` metadata resolves a compatible first parameter become methods on receiver types such as `FVector`, `FRotator`, `FQuat`, and `FTransform`. Only functions that remain static namespace functions are candidates for canonical library mapping. Manual FMath binding runs before reflected binding, so intentional aggregation can also encounter duplicate declarations.

The archived `as-library-full-namespaces` specification was introduced to reduce AI ambiguity by forbidding heuristic library shortening and requiring full registered type names. This change preserves that deterministic fallback but adds an explicit, path-keyed exception mechanism. It does not restore heuristic prefix/suffix removal or public aliases.

The parent repository owns the OpenSpec record while the implementation files live in the `Plugins/Angelscript` submodule. Implementation therefore remains a dual-repository change and must follow the documented submodule commit order.

## Goals / Non-Goals

**Goals:**

- Provide one deterministic namespace for every reflected function-library namespace function.
- Make `FMath::` the sole default spelling for the aggregated manual and reflected Math surface.
- Allow projects to assign exact function-library classes to canonical namespaces through restart-required settings keyed by stable Unreal class path.
- Preserve type receiver methods and intentional type-static helper namespaces.
- Detect invalid configuration and unsafe declaration collisions before publishing a partially initialized script API.
- Make the initialized AS engine the only source of truth consumed by dumps, offline bundles, Static JIT, editor tooling, and AI-facing inventories.

**Non-Goals:**

- Do not implement `Math::` or `MathLibrary::` compatibility aliases, compiler redirects, fix-its, or deprecation windows.
- Do not reintroduce prefix/suffix trimming, wildcard matching, regex rules, or convention-based renaming.
- Do not rename type receiver APIs such as `FVector::`, `FRotator::`, `FQuat::`, or `FTransform::`.
- Do not change Unreal Engine headers or their `ScriptName` / `ScriptMethod` metadata.
- Do not redesign function-level `ScriptName`, global-scope functions, or ordinary class/type aliases.
- Do not add namespace rewriting to export consumers.

## Decisions

### 1. Call the setting a canonical mapping, not an alias

Add a serializable settings record and a restart-required array to `UAngelscriptSettings`:

```cpp
USTRUCT()
struct ANGELSCRIPTRUNTIME_API FAngelscriptFunctionLibraryNamespaceMapping
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere)
	FSoftClassPath LibraryClass;

	UPROPERTY(EditAnywhere)
	FString Namespace;
};

UPROPERTY(
	Config,
	EditDefaultsOnly,
	Category = "Angelscript|Namespaces",
	Meta = (ConfigRestartRequired = true, TitleProperty = "LibraryClass"))
TArray<FAngelscriptFunctionLibraryNamespaceMapping>
	CanonicalFunctionLibraryNamespaces;
```

The built-in CDO defaults are the exact mappings:

```text
/Script/Engine.KismetMathLibrary                       -> FMath
/Script/AngelscriptRuntime.AngelscriptMathLibrary      -> FMath
```

Class paths are selected instead of `ScriptName`, short class names, prefixes, or source namespace strings because paths remain unambiguous across modules and do not make the setting depend on the behavior it is overriding. Multiple different class paths may intentionally target one namespace. Repeated identical entries are collapsed; repeated entries for one class path with different namespaces are configuration errors. The settings/config serialization test must document how a project clears or replaces the default array before supplying a different mapping for a built-in class.

An alternative public alias list was rejected because it increases the discoverable surface. A prefix/suffix rules engine was rejected because it recreates the inference problem that `as-library-full-namespaces` removed. A hard-coded Math-only branch was rejected because the user requirement is a reusable Blueprint/function-library policy.

### 2. Build one immutable resolver per Angelscript engine

Create `Core/AngelscriptLibraryNamespaceResolver.h/.cpp` with runtime-internal `FAngelscriptLibraryNamespaceResolver`. It validates the settings snapshot once, normalizes class paths to `FTopLevelAssetPath`, and stores an immutable `TMap<FTopLevelAssetPath, FString>`.

`FAngelscriptTypeDatabase` owns a shared immutable resolver for its engine context. The database-aware `FAngelscriptFunctionSignature` constructors use that resolver explicitly, including parallel reflection preparation; they must not read mutable global settings or rely on a thread-local current-engine scope. Any remaining constructor/call site that can create a reflected static signature without its target type database must be removed or routed through the database-aware form.

Unresolved-but-syntactically-valid soft class paths remain in the map without loading assets or modules. They become active only when a matching UClass participates in binding. Empty paths, invalid top-level class paths, empty namespaces, invalid AS qualified identifiers, and conflicting duplicate entries fail engine binding through the existing initialization/registration failure publication path.

The rejected alternatives were reading the settings CDO for every signature, which makes parallel preparation and test isolation unclear, and adding process-global resolver state, which would violate the established multi-engine containment direction.

### 3. Resolve only namespace-function placement with explicit precedence

For a reflected static UFunction, placement proceeds in this order:

1. Resolve valid `ScriptMethod` / `ScriptMixin` receiver placement. A matched receiver remains a method and never consults the canonical library map.
2. If the function remains static and its owner class has an exact canonical mapping, use the mapped namespace.
3. If an internal mixin owner has a class `ScriptName` specifically to host valid non-receiver factory helpers, preserve that explicit type-static namespace behavior (for example `UAngelscriptFQuatLibrary` -> `FQuat`).
4. Otherwise use the owner's registered Angelscript type name.

Ordinary Blueprint function-library class `ScriptName` metadata is not a fallback namespace source. Consequently, clearing the built-in `UKismetMathLibrary` mapping produces the deterministic full fallback `UKismetMathLibrary`, not `MathLibrary`.

This separates two currently conflated uses of class `ScriptName`: engine library shortening and intentional static factories on internal mixin libraries. It preserves the latter without allowing `UKismetMathLibrary` metadata to create another Math spelling.

### 4. Collapse the Math special cases at their sources

`Bind_FMath.cpp` always opens `FMath` and no longer reads `MathNamespace`. `EAngelscriptMathNamespace`, `UAngelscriptSettings::MathNamespace`, and the `WITH_EDITOR` metadata mutation are removed. `UAngelscriptMathLibrary` drops `ScriptName="Math"`; its static functions reach `FMath` through the default class-path mapping. Unreal's `UKismetMathLibrary` header remains unchanged; its non-mixin static functions reach `FMath` through the other default mapping.

`Bind_FRotator.cpp` and other manual bindings that call `UKismetMathLibrary` as a C++ implementation detail retain their authored AS owners such as `FRotator`. The C++ callee class is not itself a namespace policy input.

### 5. Publish no legacy namespace

The configured engine registers only the resolved namespace. It does not register a second global function, namespace alias, type alias, hidden symbol, or compiler lookup redirect for `Math` or `MathLibrary`. Positive tests compile representative `FMath` functions from all three sources; negative tests compile the same declarations through `Math` and `MathLibrary` and require unknown-namespace/unknown-symbol diagnostics.

This strict break was selected over a hidden compiler redirect because redirects still add language machinery, migration state, and future typed-IR name identity questions. Source migration is a direct `Math::`/`MathLibrary::` to `FMath::` rewrite within the set of functions confirmed to exist in the canonical surface.

### 6. Aggregate by complete declaration identity

Manual explicit bindings publish before reflected functions. When a mapped reflected library converges on an existing `FMath` callable:

- an exact AS declaration match is one API entry; the existing explicit binding remains authoritative and the reflected duplicate is suppressed;
- the same name with a different valid parameter declaration remains an overload;
- the same callable key (namespace, name, parameter types, method constness) with a different return/declaration shape is a binding failure, not a silent suppression;
- diagnostics name the canonical namespace, incoming owner class path, incoming declaration, and existing declaration/source information available from the bound function.

The current reflected duplicate check compares name and arguments but not the complete declaration. It must be strengthened for this convergence boundary and reconciled with the exact-identity work already recorded in `improve-as-runtime-function-libraries`.

Before implementation changes registration, capture an inventory of manual `FMath`, `UAngelscriptMathLibrary`, and `UKismetMathLibrary` final declarations grouped as exact duplicate, valid overload, receiver method, or unique namespace function. This inventory is evidence, not a maintained runtime allowlist.

### 7. Exporters observe; they do not rename

Static JIT precompiled data and offline symbol export already read `asIScriptFunction::GetNamespace()`. They must continue to serialize the canonical namespace supplied by the initialized engine. Editor CodeGen, dump/state surfaces, Standalone bundle consumption, VSCode/LSP data, and future typed semantic IR must not carry a parallel namespace mapping table.

Coverage therefore tests the initialized engine and at least one serialized/offline observer. If an observer exposes `Math` or `MathLibrary`, the fix belongs at the registration source unless evidence proves the observer is independently synthesizing names.

### 8. Modify the old full-name contract explicitly

The delta for `as-library-full-namespaces` changes its unconditional rule to “exact canonical mapping first, full registered AS type name otherwise.” Its prohibition on heuristic prefix/suffix trimming remains. Subsystem full namespaces remain unchanged.

The active `improve-as-runtime-function-libraries` artifacts currently preserve `Math::WrapIndex` and other existing Math spellings. Before implementing this change, either complete and then update/archive that change, or deliberately reconcile its current spec/tasks in the same parent-repository commit. No final active requirement may simultaneously require `Math::` and `FMath::` for the same function.

## Risks / Trade-offs

- [Risk] Existing projects have many `Math::` call sites and receive a hard compile break. -> Migrate all repository-owned sources and provide a precise diagnostic/search recipe; do not dilute the single-name goal with aliases.
- [Risk] Mapping `UKismetMathLibrary` to `FMath` exposes collisions with manual binds. -> Inventory final declarations first and enforce complete-declaration collision behavior before enabling the default mapping.
- [Risk] Class `ScriptName` is also used by internal mixin libraries for static factories. -> Apply canonical mapping after receiver resolution and retain class `ScriptName` only for the explicit internal mixin static-factory case.
- [Risk] Editor-only tests can hide cooked divergence. -> Remove the editor-only metadata mutation entirely and run both normal Runtime tests and a packaged/cooked-relevant build path through the standard build entry point.
- [Risk] Config array layering can create duplicate class entries. -> Validate duplicates deterministically and document/test the exact clear-and-replace `.ini` form.
- [Risk] Parallel reflection reads mutable settings. -> Snapshot and validate the resolver before parallel prepare; all worker reads are immutable and per-engine.
- [Risk] Exporters may gain their own namespace rewrite to make a test pass. -> Specify observer-only behavior and test serialized output without adding exporter mapping logic.
- [Risk] The active FunctionLibraries change overlaps the same signature and test files. -> Make reconciliation/sequencing the first implementation task and preserve one authoritative requirement set.

## Migration Plan

1. Reconcile the active FunctionLibraries record and capture the three-source Math declaration inventory.
2. Add red tests for resolver validation, default precedence, receiver preservation, complete-declaration collisions, `FMath` visibility, and legacy namespace absence.
3. Add settings/resolver ownership and route database-aware signature construction through it.
4. Remove the Math compatibility enum/property, hard-code the manual namespace to `FMath`, remove `UAngelscriptMathLibrary`'s Math `ScriptName`, and delete the editor-only metadata mutation.
5. Migrate repository-owned tests, scripts, examples, and current documentation from `Math::` to `FMath::`; keep historical archived OpenSpec evidence unchanged.
6. Verify Static JIT and offline export consume the canonical initialized surface without observer-specific rewriting.
7. Build the plugin and run focused FunctionLibraries, Bindings/Coverage Math, StaticJIT, Dump/offline, HotReload, and Standalone suites through repository entry points.
8. Commit the `Plugins/Angelscript` submodule implementation first, then commit the parent gitlink, OpenSpec updates, and project-owned script/document migrations.

Rollback before release is a normal revert of the submodule implementation and parent change. There is no runtime compatibility switch. Stale `MathNamespace` keys in project config become inert after the property is removed and should be deleted during source/config migration.

## Open Questions

None. The user explicitly selected strict single-name publication: `FMath` is public; `Math` and `MathLibrary` are unsupported.
