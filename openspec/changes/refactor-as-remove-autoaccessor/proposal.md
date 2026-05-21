# refactor-as-remove-autoaccessor

> **Sequencing**: This change is the **first** of a two-step cleanup. It MUST land before `refactor-as-audit-remove-with-angelscript-haze`, because that follow-up restores UE-original method names (e.g. `GetInstigator`) that would otherwise collide with the auto-accessors generated for same-named UPROPERTYs. The audit/macro-removal change is blocked on this one being merged.

## Why

The fork has long maintained an "automatic property accessor" subsystem inherited from Hazelight, layered on AngelScript's stock property accessor mode:

- `AS_PROPERTY_ACCESSOR_MODE = 3` (`AngelscriptEngine.h:23-25`) enables compiler-driven `obj.X` ↔ `GetX()` / `SetX()` rewriting.
- `bAllowImplicitPropertyAccessors = true` (`AngelscriptSettings.h:55-56`) silently promotes every C++ binding whose name starts with `Get` / `Set` to a property accessor candidate.
- `Bind_BlueprintType.cpp::BindProperties()` auto-generates `GetX` / `SetX` accessors for every UPROPERTY when only one side is hand-bound, and a second pass rebinds `BlueprintGetter` / `BlueprintSetter` UFunctions under the same names.
- AS-side virtual property syntax `int X { get; set; }` and `void GetX() property { ... }` decorators feed the same trait pool.

In the AI-assisted authoring era this convenience has flipped into a liability. `obj.Foo` hides whether the access goes through a raw offset, a generated wrapper, a `BlueprintGetter` UFunction, or a manually bound method — making intent unstable for both LLMs and humans, polluting completion lists with synthetic `GetX`/`SetX` entries, and forcing the fork to maintain a 4-layer machinery (parser + builder + compiler + binding) just to keep the sugar working.

The goal of this change is to **unify AS and C++ access syntax to explicit method calls**, so that any reader (human or model) can determine the access path from the call site alone.

## What Changes

- **BREAKING**: `AS_PROPERTY_ACCESSOR_MODE` is set to `0` and the macro is deleted. Property accessor lookup (`asCCompiler::FindPropertyAccessor`) early-returns and never finds matches.
- **BREAKING**: `bAllowImplicitPropertyAccessors` setting is removed; the `OnBind` hook in `AngelscriptBinds.cpp` no longer marks bound methods with `asTRAIT_PROPERTY`.
- **BREAKING**: `BindProperties()` in `Bind_BlueprintType.cpp` (Lines ~1182-1310) drops the `bGeneratedGetter` / `bGeneratedSetter` synthesis path; only the raw-field direct-bind path (`Binds.Property()`, ~Lines 1312-1322) remains as the canonical UPROPERTY surface.
- **BREAKING**: `BindProperties()` second pass (Lines ~1601-1663) no longer rebinds `BlueprintGetter` / `BlueprintSetter` UFunctions under generated `GetX` / `SetX` names. The underlying UFunctions remain reachable through ordinary method binding under their original UFunction names.
- **BREAKING**: AngelScript virtual property syntax (`int X { get; set; }`) and the `property` decorator (`void GetX() property { }`) become parse errors with a guidance message pointing to explicit method declarations.
- **Migrate**: All in-repo `.as` scripts under `Script/` and inline AS string literals under `AngelscriptTest/` are rewritten from property-style access (`obj.Foo`, `obj.Foo = X`) to explicit method calls (`obj.GetFoo()`, `obj.SetFoo(X)`) where the access goes through a method, and remain field reads where the UPROPERTY is exposed as a raw field.
- **Cleanup**: `Documents/Knowledges/ZH/Syntax_PropertyAccessor.md` is rewritten as a "removed" historical note. `Documents/Guides/ASSDK_Fork_Differences.md` drops the PascalCase `Get` / `Set` prefix section.
- **Preserve**: Raw field UPROPERTY exposure (`obj.bHidden`, `obj.Tags`) remains intact via `Binds.Property()` — these are still field-style access, not method dispatch, and are unambiguous.
- **Preserve**: `asTRAIT_GENERATED_FUNCTION` is kept as an internal trait used by the debug server / IDE filtering pipeline; it is simply no longer set by `BindProperties` after this change.

## Capabilities

### New Capabilities

- `as-property-access-uniform`: Codifies that AngelScript user code accesses UPROPERTY data and UFunction behaviour through the same syntax surface as C++ — direct field reads for raw fields, explicit method calls for everything else — with no compiler-driven `obj.X ↔ GetX()` rewriting.

### Modified Capabilities

- None. (`Bind_BlueprintType` continues to expose UPROPERTY data; only the synthesis path inside it is removed.)

## Impact

- **AngelscriptRuntime / Core**: `AngelscriptEngine.{h,cpp}` (mode macro), `AngelscriptSettings.{h,cpp}` (setting removal), `AngelscriptBinds.{h,cpp}` (`OnBind` hook).
- **AngelscriptRuntime / Binds**: `Bind_BlueprintType.cpp` is the primary modification surface; helper functions in `AngelscriptBindHelpers.{h,cpp}` for accessor-only paths can be retired in cleanup.
- **AngelscriptRuntime / ThirdParty**: `as_compiler.cpp` (FindPropertyAccessor), `as_builder.cpp` (ValidatePropertyAccessorFunc, virtual property split), `as_parser.cpp` (PROPERTY_TOKEN decorator + ParseVirtualPropertyDecl), `as_config.h` (`Get` / `Set` prefix constants). These are kept in the vendored tree but their entry points are guarded so future re-enablement requires only flipping the engine property.
- **AngelscriptTest**: Inline AS string literals across automation tests are rewritten; no test infrastructure changes.
- **Script**: All `.as` example files under `Script/Examples/Core/`, `Script/Examples/EnhancedInput/`, `Script/Examples/Extended/`, `Script/Automation/`, `Script/Tests/` are migrated.
- **Documents**: `Knowledges/ZH/Syntax_PropertyAccessor.md`, `Guides/ASSDK_Fork_Differences.md`, plus a one-line entry in `AGENTS.md` "Recently Completed Milestones".
- **Editor / IDE**: VSCode AngelScript extension completion lists shrink (no synthetic `GetX`/`SetX`) — this is a positive UX change but worth calling out for users who relied on the auto-completion behaviour.
