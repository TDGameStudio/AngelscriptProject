## 1. Optional GameplayTag plugin

- [ ] 1.1 <!-- TDD --> Create the optional GameplayTag plugin boundary and move the GameplayTag binding/cache/replay behavior out of `AngelscriptRuntime`. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.GameplayTags" -Label angelscript-gameplaytags-extension-1 -TimeoutMs 900000`.
- [ ] 1.2 <!-- TDD --> Wire the plugin to the runtime extension seam so it can register, unregister, and replay cached tags onto the current engine. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-gameplaytags-extension-2 -TimeoutMs 900000 -NoXGE`.

## 2. Runtime cleanup and validation

- [ ] 2.1 <!-- Non-TDD --> Remove the core runtime's direct GameplayTag ownership if no other runtime code still needs it, and confirm the optional plugin is now the only GameplayTag binding path. Verify with `rg -n "Bind_FGameplayTag|AngelscriptGameplayTagsLookup|AngelscriptRebindGameplayTagsToCurrentEngine|GameplayTags" Plugins\Angelscript\Source\AngelscriptRuntime Plugins\AngelscriptGAS\Source`.
- [ ] 2.2 <!-- Non-TDD --> Run the GameplayTag extension tests and a full build to confirm the feature still works when enabled and imposes no runtime cost when disabled. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.GameplayTags" -Label angelscript-gameplaytags-extension-3 -TimeoutMs 900000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-gameplaytags-extension-4 -TimeoutMs 1800000`.
- [ ] 2.3 <!-- Non-TDD --> Run `openspec validate refactor-as-gameplaytags-optional-plugin --strict --json` from the project root and confirm the change is ready for implementation.
