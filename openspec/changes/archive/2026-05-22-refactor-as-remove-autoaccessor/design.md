# Design: refactor-as-remove-autoaccessor

## Context

The fork's automatic property accessor stack has four interacting layers:

1. **Engine setting**: `AS_PROPERTY_ACCESSOR_MODE = 3` (`AngelscriptEngine.h:24`), pushed into the AngelScript engine via `Engine->SetEngineProperty(asEP_PROPERTY_ACCESSOR_MODE, ...)` (`AngelscriptEngine.cpp:1046, 1826`). Mode 3 means: property-style access on bound C++ classes works, but only if the underlying method carries `asTRAIT_PROPERTY`.

2. **Implicit promotion**: `bAllowImplicitPropertyAccessors = true` (default, `AngelscriptSettings.h:55-56`) drives the `OnBind` hook in `AngelscriptBinds.cpp` to call `SetProperty(true)` on every newly bound method, indiscriminately marking all `Get*` / `Set*` C++ bindings as property accessors.

3. **Auto-generation in `BindProperties()`** (`Bind_BlueprintType.cpp:1115-1322`): for every UPROPERTY, if a hand-bound `GetX()` or `SetX()` is missing, a synthetic accessor is generated that reads/writes the property at its computed offset (`FAngelscriptBindHelpers::GetObjectFromProperty`, `SetValueFromProperty_Byte/DWord/QWord`, etc.). A second pass at lines 1601-1663 rebinds `BlueprintGetter` / `BlueprintSetter` UFunctions under the generated names, so script callers go through BP user logic instead of raw offset writes.

4. **AS-side syntax sugar**: in `as_parser.cpp` the `property` decorator (token `PROPERTY_TOKEN`) and the virtual-property block (`int X { get; set; }`) feed the same trait into hand-written script methods. `as_compiler.cpp::FindPropertyAccessor` (Lines 13989-14430) is the runtime piece that resolves `obj.X` and `obj.X = ...` expressions to the matching `GetX` / `SetX` method.

The stack has worked correctly for years, but its cost has shifted. Original users — humans coming from Blueprint — benefited from the BP-like dot syntax. Current users — increasingly LLMs writing UE plugin code — pay a comprehension tax: `obj.X` could mean a raw field read, a generated offset read, a `BlueprintGetter` UFunction call, or a hand-bound C++ method, with no syntactic distinction. The completion list pollution (every UPROPERTY auto-emits synthetic `GetX` / `SetX`) compounds the noise.

UPROPERTY data does not actually need this sugar to remain accessible: raw fields are already exposed via `Binds.Property()` as direct `obj.Field` reads (offset-based, zero overhead, identical to vanilla AngelScript class-member access), and `BlueprintGetter` / `BlueprintSetter` UFunctions are reachable as ordinary methods under their declared UFunction names. The accessor system was always purely syntactic.

## Goals / Non-Goals

**Goals:**

- Make AngelScript and C++ access syntax visually identical: field reads use `obj.Field`; method calls use `obj.Method()`. No compiler rewriting between the two.
- Keep all existing UPROPERTY data reachable from script after the change. Either as a raw field (the default for plain UPROPERTYs) or via an explicit method call to a `BlueprintGetter`/`BlueprintSetter` UFunction.
- Migrate every `.as` script and inline AS literal in the repository in the same change so the repo is buildable and test suites are green at merge time.
- Remove the four control points in a single coherent step so there is no half-disabled state where some property syntax works and other parts mysteriously do not.

**Non-Goals:**

- Do not delete the vendored AngelScript source (`ThirdParty/angelscript/source/`). The compiler/builder/parser code that supports property accessors stays in the tree but its entry points are guarded.
- Do not redesign the `BindProperties` pipeline. Only the synthesis-and-rebind paths are removed; the raw-field direct-bind path (`Binds.Property()`) is unchanged.
- Do not remove the `BlueprintGetter` / `BlueprintSetter` metadata processing in the preprocessor or class generator. UFunctions tagged with these specifiers continue to exist and remain individually callable from script.
- Do not touch the `Reference/AngelscriptAura/` or any other Reference-only material. These are external corpora, not part of the project deliverable.
- Do not modify the DebugServer V2 wire format. The `asTRAIT_GENERATED_FUNCTION` filtering keeps working; it just no longer matches anything because no functions are auto-generated.

## Decisions

- **D1 — Full removal over half-measure.** Set `AS_PROPERTY_ACCESSOR_MODE = 0` AND remove `bAllowImplicitPropertyAccessors` AND drop `BindProperties` synthesis AND make virtual-property syntax a parse error AND remove the `property` decorator. A partial disable (e.g. only flipping `bAllowImplicitPropertyAccessors`) leaves virtual-property syntax legal but non-functional, which is more confusing than the current state. The user explicitly chose "full closure" in plan-mode clarification.

- **D2 — Preserve raw-field exposure.** Plain UPROPERTYs stay accessible as `actor.bHidden`, `mesh.RelativeLocation`, etc. via the existing `Binds.Property()` path in `BindProperties` (Lines ~1312-1322). This is offset-based field access, not method dispatch, so there is no naming ambiguity. The user reading `actor.bHidden` immediately knows it is a field. Only the synthetic `GetX` / `SetX` generation is removed.

- **D3 — `BlueprintGetter` / `BlueprintSetter` UFunctions become explicit methods.** When a UPROPERTY declares `BlueprintGetter=GetFoo`, the underlying `GetFoo` UFunction is bound under its own UFunction name through the standard UFunction binding path. Script callers must write `actor.GetFoo()` explicitly. This loses the "transparent BP getter" sugar but preserves full functional equivalence; the underlying UFunction body still runs.

- **D4 — Vendored AngelScript code stays, entry points are guarded.** `as_compiler.cpp::FindPropertyAccessor` already early-returns when `propertyAccessorMode == 0`; we keep the function intact. `ParseVirtualPropertyDecl` and the `PROPERTY_TOKEN` decorator paths in `as_parser.cpp` are modified to emit a clear error message ("virtual property syntax has been removed; use explicit GetX/SetX methods") rather than being deleted, so future re-enablement is a single-flag flip rather than a vendored-code restoration.

- **D5 — Migrate scripts in the same change.** Splitting "remove runtime" and "migrate scripts" into two PRs would leave an intermediate state where the repository does not build. Instead, all `Script/**/*.as`, `AngelscriptTest/` inline AS literals, and any `.as` content embedded in test cases are rewritten in this change's tasks. Verification is `Tools\RunTests.ps1 -Suite Functional` showing the 275/275 baseline holds.

- **D6 — `asTRAIT_GENERATED_FUNCTION` trait is preserved.** The trait is still set in a couple of remaining sites (debugger metadata, future use). `BindProperties` simply stops setting it, but downstream filtering code (DebugServer, code coverage) remains correct because it now matches an empty set.

## Risks / Trade-offs

- **Risk: hidden script breakage in non-obvious sites** → Mitigation: a tasks-level `rg -n '\.[A-Z][a-zA-Z]+\s*[=;,)]'` sweep across `Script/`, `Plugins/Angelscript/Source/AngelscriptTest/`, and any `.cpp` file containing inline AS string literals catches the bulk of property-style accesses. A second sweep for `\{\s*get\s*\{` and `void\s+Get\w+\s*\(\s*\)\s+property` covers virtual-property syntax and the `property` decorator. Failure mode is a script compile error, surfaced cleanly by `RunTests.ps1`.

- **Risk: `BlueprintGetter` UFunctions disappear from script-visible surface when their UFunction name differs from the property name** → Mitigation: in practice almost all `BlueprintGetter=GetFoo` declarations name the UFunction `GetFoo` for property `Foo`, so they remain reachable as `actor.GetFoo()`. Edge cases where the UFunction name is unrelated need spot fixes. The proposal's tasks include a search for `BlueprintGetter=` and `BlueprintSetter=` metadata to enumerate all such properties.

- **Risk: virtual-property block parse error wording is unclear** → Mitigation: the parser emits a single targeted error string referencing this change and telling the user to declare explicit `GetX`/`SetX` methods. Tasks include a unit test asserting the error message format.

- **Risk: VSCode AngelScript extension developer expectations** → Mitigation: the extension consumes the debug database which already filters `asTRAIT_GENERATED_FUNCTION`. After this change the database simply contains fewer functions; no protocol break. Documented in the proposal Impact section so users running the extension know completion lists will shrink.

- **Trade-off: longer keystrokes in scripts.** `actor.GetActorLocation()` is 9 characters longer than `actor.ActorLocation`. We accept this for the sake of unambiguous semantics — the same trade C++ programmers make every day.

## Migration Plan

1. **Phase 1 — Engine config & binding API surface.** Flip the mode macro to 0, remove the implicit-promotion setting, strip the `OnBind` `SetProperty(true)` injection. After this phase the runtime still has the auto-generation path active in `BindProperties`, so most things still work via the existing trait-marked methods, but no new methods get marked.

2. **Phase 2 — Drop `BindProperties` auto-generation.** Remove the `bGeneratedGetter` / `bGeneratedSetter` block and the `BlueprintGetter` / `BlueprintSetter` second pass. After this phase scripts that used `actor.SomeBPProperty` syntax for BP-getter properties stop compiling.

3. **Phase 3 — Disable AS-side syntax sugar.** Make `PROPERTY_TOKEN` decorator and `ParseVirtualPropertyDecl` emit guidance errors. The `FindPropertyAccessor` early-return already handles mode 0.

4. **Phase 4 — Migrate in-repo scripts.** Run sweeps over `Script/**/*.as` and `AngelscriptTest/` inline AS literals; rewrite to explicit method calls or field reads as appropriate. Compile-time check: `Tools\RunBuild.ps1`. Runtime check: `Tools\RunTests.ps1 -Suite Functional`.

5. **Phase 5 — Documentation & milestone update.** `Documents/Knowledges/ZH/Syntax_PropertyAccessor.md` becomes a removal note. `Documents/Guides/ASSDK_Fork_Differences.md` drops the PascalCase prefix section. `AGENTS.md` Recently Completed Milestones gains a one-liner.

## Open Questions

- None — the user has confirmed: (a) full closure rather than partial disable, (b) sequential dependency with `refactor-as-audit-remove-with-angelscript-haze`, (c) full in-repo script migration in this change.
