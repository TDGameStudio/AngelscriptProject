## 1. Build Rule Boundary

- [ ] 1.1 <!-- Non-TDD --> Inspect `Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs` and keep the module root publicly includable unless validation proves a narrower public include setup works.
- [ ] 1.2 <!-- Non-TDD --> Remove the hardcoded `Plugins/Angelscript/Source/AngelscriptTest` private include path from `Plugins/AngelscriptGAS/Source/AngelscriptGASTest/AngelscriptGASTest.Build.cs` while retaining the `AngelscriptTest` dependency.

## 2. Public Helper Documentation

- [ ] 2.1 <!-- Non-TDD --> Update `Documents/Guides/TestConventions.md` so extension test modules are told to consume reusable helpers through `AngelscriptTest` and documented `Shared/...` or `AngelScriptSDK/...` include paths.
- [ ] 2.2 <!-- Non-TDD --> Correct stale helper path references such as `Bindings/Shared/AngelscriptBindings*.h` to the actual `Shared/AngelscriptBindings*.h` layout.
- [ ] 2.3 <!-- Non-TDD --> Document that `Core`, `Debugger`, `Dump`, `Preprocessor`, `ClassGenerator`, and themed fixture directories are internal unless a later OpenSpec change promotes them.

## 3. Consumer Verification

- [ ] 3.1 <!-- Non-TDD --> Run `rg -n "Angelscript.*Source.*AngelscriptTest|PrivateIncludePaths.*AngelscriptTest|PublicIncludePaths.*AngelscriptTest" Plugins -g "*.Build.cs"` and confirm extension plugins no longer hardcode the `AngelscriptTest` source path.
- [ ] 3.2 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label angelscript-test-helper-api -TimeoutMs 180000 -NoXGE` to verify module compilation.
- [ ] 3.3 <!-- Non-TDD --> Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.GAS." -Label angelscript-gas-helper-api -TimeoutMs 600000` to verify the first extension consumer still runs through documented helpers.

## 4. OpenSpec Validation

- [ ] 4.1 <!-- Non-TDD --> Run `openspec validate "refactor-angelscript-test-helper-api" --strict --json` and fix any artifact structure or capability errors before apply.
