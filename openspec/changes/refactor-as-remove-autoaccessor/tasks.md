> **Sequencing**: This is the **first** of a two-step cleanup. The follow-up change `refactor-as-audit-remove-with-angelscript-haze` is blocked on this one being merged — do not start it until tasks 1.1–5.5 below are all complete and the change is archived.

## 1. Engine config & binding API surface

- [ ] 1.1 <!-- Non-TDD --> Set `AS_PROPERTY_ACCESSOR_MODE` to `0` in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h:23-25` and remove the `#ifndef` guard once the macro is no longer overridable; verify with `rg -n "AS_PROPERTY_ACCESSOR_MODE" Plugins\Angelscript\Source` returns only the deletion sites and the `Engine->SetEngineProperty(asEP_PROPERTY_ACCESSOR_MODE, 0)` lines in `AngelscriptEngine.cpp:1046, 1826`.
- [ ] 1.2 <!-- Non-TDD --> Remove the `bAllowImplicitPropertyAccessors` UPROPERTY from `AngelscriptSettings.h:55-56` and any `GetDefault<UAngelscriptSettings>()->bAllowImplicitPropertyAccessors` reads; verify with `rg -n "bAllowImplicitPropertyAccessors" Plugins\Angelscript`.
- [ ] 1.3 <!-- Non-TDD --> Remove the `OnBind` hook in `AngelscriptBinds.cpp` (~Lines 487-511) that calls `Function->traits.SetTrait(asTRAIT_PROPERTY, true)`; verify with `rg -n "asTRAIT_PROPERTY" Plugins\Angelscript\Source\AngelscriptRuntime` shows the trait is only referenced by virtual-property removal sites in §3.
- [ ] 1.4 <!-- Non-TDD --> `Tools\RunBuild.ps1 -Label as-remove-autoaccessor-phase1 -TimeoutMs 180000`.

## 2. Drop BindProperties auto-generation

- [ ] 2.1 <!-- TDD --> In `Bind_BlueprintType.cpp:1115-1322` remove the `bGeneratedGetter` / `bGeneratedSetter` synthesis path (the `if (bHasSetter || bHasGetter) { ... }` block, ~Lines 1182-1310). Preserve the `Binds.Property()` direct-bind path (~Lines 1312-1322). Add a runtime test that compiles a UPROPERTY-rich actor binding from script and asserts (a) `actor.bField` works and (b) `actor.GetField()` does not compile.
- [ ] 2.2 <!-- TDD --> In `Bind_BlueprintType.cpp` remove the `BlueprintGetter` / `BlueprintSetter` second pass (~Lines 1601-1663). Add a test that declares a UPROPERTY with `BlueprintGetter=GetFoo` and asserts the underlying `GetFoo` UFunction remains callable as `obj.GetFoo()` via the ordinary UFunction binding path.
- [ ] 2.3 <!-- Non-TDD --> Sweep `AngelscriptBindHelpers.{h,cpp}` for accessor-only helpers (`GetObjectFromProperty`, `GetValueFromProperty_*`, `SetObjectFromProperty`, `SetValueFromProperty_Byte/DWord/QWord`) that are now unused; remove unreferenced helpers; verify with `rg -n` after each removal.
- [ ] 2.4 <!-- Non-TDD --> `Tools\RunBuild.ps1 -Label as-remove-autoaccessor-phase2 -TimeoutMs 180000`.

## 3. Disable AS-side syntax sugar

- [ ] 3.1 <!-- TDD --> In `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:3216-3230` and `:5118-5128` remove `IdentifierIs(t1, PROPERTY_TOKEN)` from the decorator-recognition predicates; on `PROPERTY_TOKEN` occurrence at decorator position emit `WriteError(TXT_PROPERTY_DECORATOR_REMOVED, file, t1)` (new string in `as_texts.h`). Add a parse-failure test asserting the error message.
- [ ] 3.2 <!-- TDD --> In `as_parser.cpp::ParseVirtualPropertyDecl` (Line 3468) replace the function body with an immediate `WriteError(TXT_VIRTUAL_PROPERTY_REMOVED, ...)` and return null. Add a parse-failure test for `int X { get; set; }`.
- [ ] 3.3 <!-- Non-TDD --> In `as_builder.cpp:1724-1746` (`ValidatePropertyAccessorFunc`) and `:5380-5443` (virtual-property split): leave the code in place since neither is reachable after 3.1 / 3.2; add a `// Unreachable after refactor-as-remove-autoaccessor` comment.
- [ ] 3.4 <!-- Non-TDD --> Confirm `as_compiler.cpp:13991` early-return handles `propertyAccessorMode == 0` correctly; add a comment cross-referencing this change.
- [ ] 3.5 <!-- Non-TDD --> `Tools\RunBuild.ps1 -Label as-remove-autoaccessor-phase3 -TimeoutMs 180000`.

## 4. Migrate in-repo scripts and inline AS

- [ ] 4.1 <!-- Non-TDD --> Sweep `Script/**/*.as` for property-style access. Discovery commands: `rg -n '[A-Za-z_]\w*\.[A-Z][A-Za-z0-9_]*\s*[=;,)]' Script` and `rg -n '\{\s*get\s*\{|\bproperty\s*\{' Script`. Rewrite each match: raw-field UPROPERTY → keep as-is; `BlueprintGetter` / `BlueprintSetter` access → explicit `GetFoo()` / `SetFoo(V)`; `property`-decorated methods or virtual-property blocks → split into separate `GetX` / `SetX` methods.
- [ ] 4.2 <!-- Non-TDD --> Sweep `Plugins/Angelscript/Source/AngelscriptTest/**/*.cpp` for AS string literals. Discovery: `rg -n 'TEXT\(R"\(\s*[^)]*\.[A-Z]' Plugins\Angelscript\Source\AngelscriptTest` and `rg -n '\{\s*get\s*\{' Plugins\Angelscript\Source\AngelscriptTest`. Rewrite per the same rules.
- [ ] 4.3 <!-- Non-TDD --> Verify zero remaining property-style or virtual-property syntax: both sweeps return only false positives (struct field access, etc.). Document any false positive patterns in a comment for future maintainers.
- [ ] 4.4 <!-- TDD --> `Tools\RunTests.ps1 -Group AngelscriptFunctional -Label as-remove-autoaccessor-script-migration -TimeoutMs 900000 -- -AngelscriptTestUseScanFreeStartupEngine`. Required: 275/275 baseline tests pass; no test newly disabled.

## 5. Documentation & milestone

- [ ] 5.1 <!-- Non-TDD --> Rewrite `Documents/Knowledges/ZH/Syntax_PropertyAccessor.md` as a removal note: keep a brief "what this used to do" preamble, then a "removed in `refactor-as-remove-autoaccessor`" section pointing at the new explicit-method convention. Preserve the original §1-§3 implementation detail as appendix for historical reference.
- [ ] 5.2 <!-- Non-TDD --> Remove the PascalCase `Get` / `Set` prefix section from `Documents/Guides/ASSDK_Fork_Differences.md`; keep other fork-difference entries intact.
- [ ] 5.3 <!-- Non-TDD --> Add a "Recently Completed Milestones" entry to `AGENTS.md` and `AGENTS_ZH.md` referencing this change ID.
- [ ] 5.4 <!-- TDD --> Final regression: `Tools\RunBuild.ps1 -Label as-remove-autoaccessor-final -TimeoutMs 180000` and `Tools\RunTests.ps1 -Group AngelscriptFunctional -Label as-remove-autoaccessor-final -TimeoutMs 900000 -- -AngelscriptTestUseScanFreeStartupEngine`. Both must be green.
- [ ] 5.5 <!-- Non-TDD --> `openspec validate refactor-as-remove-autoaccessor --strict --json` exits 0.
