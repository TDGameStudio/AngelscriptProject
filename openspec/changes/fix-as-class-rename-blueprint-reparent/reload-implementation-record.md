# AS class rename hot reload implementation record

## Scope

This record covers the hot-reload work for Angelscript `UCLASS` renames where a Blueprint derives from the AS-generated class.

The implemented behavior follows UE's official CoreRedirect mechanism instead of adding an Angelscript-specific redirect setting. The relevant official form is:

```ini
[CoreRedirects]
+ClassRedirects=(OldName="/Script/Angelscript.AOldScriptClass",NewName="/Script/Angelscript.ANewScriptClass")
```

## Runtime behavior

- AS generated classes live in the synthetic package `/Script/Angelscript`.
- During class-generator setup, `FAngelscriptClassGenerator::Analyze` first computes added, removed, and changed AS classes.
- After analysis and before dependency reload requirement propagation, `FAngelscriptClassGenerator::TryGenerateClassRenameRedirects` checks each module for an unambiguous rename shape:
  - exactly one removed AS `UCLASS`;
  - exactly one added AS `UCLASS`;
  - no struct class;
  - no statics class;
  - no same-name replacement already present.
- If that shape is found, `FAngelscriptClassRedirects::TryAddGeneratedCoreRedirect` writes and registers a class redirect from the removed AS class name to the added AS class name.
- During full reload class setup, `FAngelscriptClassGenerator::ResolveClassRedirectReplacedClass` asks `FCoreRedirects::FindPreviousNames` for the new class and resolves those previous names against `ModuleData.RemovedClasses`.
- When a removed `UASClass` is resolved, it becomes the `ReplacedClass` for the new AS class. The existing reload path then links `OldClass->NewerVersion = NewClass`, sets the newer-version flags, and broadcasts `OnClassReload(OldClass, NewClass)`.
- The editor Blueprint repair remains on the existing hot-reload path. The generator only supplies the missing old-class to new-class replacement identity.

## Generated redirect writing

- Production writes target project `Config/DefaultEngine.ini`.
- The generated value is stored under `[CoreRedirects]` as `+ClassRedirects=(OldName="...",NewName="...")`.
- The same redirect is registered immediately with `FCoreRedirects::AddRedirectList`, so the current editor session can reparent live Blueprint children without requiring an editor restart.
- Existing identical redirects are not duplicated.
- Conflicting generated redirects for the same old class and stale reverse redirects are removed from the generated target before writing the new pair.
- Tests can override the target ini path through `FAngelscriptClassRedirects::SetCoreRedirectTargetIniOverrideForTesting`.
- Automation writes to `Saved/Automation/CoreRedirects/...` and deletes those files in teardown, so tests do not leave project config changes.

## Deliberate limits

- Ambiguous reloads are not guessed. If more than one AS `UCLASS` is removed or more than one AS `UCLASS` is added, no automatic redirect is generated.
- Struct, enum, delegate, function, and property redirects are out of scope.
- Offline asset migration and Blueprint bulk resave are out of scope.
- Hand-authored redirects still use UE's normal `[CoreRedirects] +ClassRedirects` format.

## Test coverage

Coverage lives in `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadClassRenameTests.cpp`.

- `AmbiguousRenameDoesNotInferRedirectAndOrphansBlueprintChild`
  - Proves ambiguous rename reloads do not infer redirects.
  - Verifies the Blueprint child stays on the removed AS class husk.
- `ManualReparentRecoversBlueprintChildAfterAmbiguousRename`
  - Proves manual Blueprint parent reassignment still repairs ambiguous rename cases.
- `ConfiguredRenameRedirectReparentsBlueprintChildAfterReload`
  - Proves a registered UE class redirect causes hot reload to reparent the Blueprint child.
- `AutomaticRenameRedirectWritesProjectConfigAndReparentsBlueprintChildAfterReload`
  - Proves an unambiguous AS class rename writes a generated CoreRedirect ini entry.
  - Proves the same generated redirect is registered in `FCoreRedirects` during the current session.
  - Proves the Blueprint child is reparented to the renamed AS class after reload.
- `IniFullPathRedirectWinsOverShortNameRedirectAfterReload`
  - Proves physical `[CoreRedirects]` ini ingestion works for AS generated class paths.
  - Proves full `/Script/Angelscript.<ClassName>` redirects are the intended AS format.
- `InvalidRenameRedirectDoesNotReplaceUnrelatedRemovedClass`
  - Proves a redirect from an unrelated missing old class does not cross-link an unrelated removed AS class.
- `TwoStepRenameRedirectReachesFinalClass`
  - Proves sequential configured renames can move a Blueprint child through intermediate and final AS parent classes.
- `AutomaticRenameBackReparentsBlueprintChildToFreshOriginalName`
  - Proves automatic generated redirects also handle rename-back cases and remove stale reverse generated entries from the generated ini target.

## Config pollution checks

The class rename tests use a scoped generated redirect target under `Saved/Automation/CoreRedirects`. After the final verification run:

- `Config/DefaultEngine.ini` had no `HotReloadClassRename`, `AHotReloadClassRename`, or `+ClassRedirects` entries from automation.
- `Saved/Automation/CoreRedirects` existed and contained zero files.

## Verification

Final local verification used the project wrappers:

```powershell
Tools\RunBuild.ps1 -Label as-class-redirect-test-module-final-check -TimeoutMs 180000 -NoXGE "-Module=AngelscriptTest"
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.ClassRename" -Label "hotreload-class-rename-core-redirect-final-check" -TimeoutMs 300000
```

Observed results:

- Build returned `FinalExitCode: 0`.
- Automation returned `total=8 passed=8 failed=0 skipped=0`.

## Commits

- Plugin submodule: `4261b9c [Angelscript] Fix: generate CoreRedirects for AS class renames`
- Parent OpenSpec record: `d6a0d07 [OpenSpec] Docs: record AS class rename CoreRedirect flow`

