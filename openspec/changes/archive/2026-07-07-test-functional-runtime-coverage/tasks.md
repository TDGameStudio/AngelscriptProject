## 1. Objects and operators runtime assertions

- [ ] 1.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Functional/Objects/AngelscriptObjectModelTests.cpp` so the supported object-model cases assert real runtime behavior and any unsupported paths are labeled as explicit negative boundaries. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional.Objects." -Label functional-runtime-objects -TimeoutMs 600000`.
- [ ] 1.2 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Functional/Operators/AngelscriptOperatorTests.cpp` so the supported operator cases assert real runtime behavior and any unsupported paths are labeled as explicit negative boundaries. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional.Operators." -Label functional-runtime-operators -TimeoutMs 600000`.

## 2. Handles and inheritance runtime assertions

- [ ] 2.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Functional/Handles/AngelscriptHandleTests.cpp` so the supported handle cases assert real runtime behavior and any unsupported paths are labeled as explicit negative boundaries. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional.Handles." -Label functional-runtime-handles -TimeoutMs 600000`.
- [ ] 2.2 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Functional/Inheritance/AngelscriptInheritanceTests.cpp` so the supported inheritance cases assert real runtime behavior and any unsupported paths are labeled as explicit negative boundaries. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional.Inheritance." -Label functional-runtime-inheritance -TimeoutMs 600000`.

## 3. Documentation and full-prefix verification

- [ ] 3.1 <!-- Non-TDD --> Update `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md` to describe the restored functional runtime behavior surface and the explicit negative boundaries that remain. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Functional." -Label functional-runtime-coverage -TimeoutMs 900000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label functional-runtime-coverage -TimeoutMs 180000`.
