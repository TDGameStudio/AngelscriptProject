## 1. Optional GameplayTag plugin

- [x] 1.1 <!-- TDD --> Create the optional `AngelscriptGameplayTags` plugin boundary and move the GameplayTag binding/cache/replay behavior out of `AngelscriptRuntime`.
- [x] 1.2 <!-- TDD --> Wire the plugin to the runtime extension seam so it can register, unregister, and replay cached tags onto the current engine.
- [x] 1.3 <!-- TDD --> Move the editor GameplayTags change delegate listener into `AngelscriptGameplayTagsEditor`.
- [x] 1.4 <!-- TDD --> Move GameplayTag binding/function-library/editor tests under `AngelscriptGameplayTagsTest` with the `Angelscript.GameplayTags.*` prefix.

## 2. Runtime cleanup and validation

- [x] 2.1 <!-- Non-TDD --> Remove `GameplayTags` module dependencies and GameplayTag ownership from `AngelscriptRuntime` and `AngelscriptEditor`.
- [x] 2.2 <!-- Non-TDD --> Update `AngelscriptGAS` so it depends on both `Angelscript` and `AngelscriptGameplayTags`.
- [x] 2.3 <!-- Non-TDD --> Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-gameplaytags-split-build -TimeoutMs 1800000 -NoXGE`.
- [x] 2.4 <!-- Non-TDD --> Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.GameplayTags" -Label angelscript-gameplaytags-tests -TimeoutMs 900000`.
- [x] 2.5 <!-- Non-TDD --> Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.GAS" -Label angelscript-gas-gameplaytags-dependency -TimeoutMs 900000`.
- [x] 2.6 <!-- Non-TDD --> Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Extension" -Label angelscript-extension-registry-regression -TimeoutMs 900000`.
- [x] 2.7 <!-- Non-TDD --> Confirm no old GameplayTag binding/test prefixes remain in core with focused `rg` scans.
- [x] 2.8 <!-- Non-TDD --> Run `openspec validate refactor-as-gameplaytags-optional-plugin --strict --json` from the project root.
- [x] 2.9 <!-- Non-TDD --> Add `Angelscript.GameplayTags` to the all-suite and coarse-shard test definitions.
- [x] 2.10 <!-- Non-TDD --> Verify full suite with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite All -LabelPrefix all-gameplaytags-split-final -TimeoutMs 900000 -ContinueOnFail` (`37/37` prefixes, `1836/1836 PASS`).
