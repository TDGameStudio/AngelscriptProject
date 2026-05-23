## 1. Geometry and math binding gaps

- [ ] 1.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptBox3fBindingsTests.cpp` and `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptSphere3fBindingsTests.cpp` so the FBox, FBox3f, and FPlane cases become executable assertions or explicit negative contracts instead of silent binding-gap placeholders. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure-geometry -TimeoutMs 600000`.

## 2. Platform, path, and profiler binding gaps

- [ ] 2.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptPathsBindingsTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptPlatformMiscBindingsTests.cpp`, and `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptCpuProfilerBindingsTests.cpp` so the FApp, FGenericPlatformMisc, and FCpuProfilerTraceScoped cases are explicit and runnable. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure-platform -TimeoutMs 600000`.

## 3. String, delegate, memory, and component-adjacent binding gaps

- [ ] 3.1 <!-- TDD --> Update `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFStringBindingsTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptFileAndDelegateBindingsTests.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMemoryReaderBindingsTests.cpp`, and `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMeshComponentBindingsTests.cpp` so the affected cases become executable assertions or explicit negative contracts with concrete reasons. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure-string-memory -TimeoutMs 600000`.

## 4. Documentation and verification

- [ ] 4.1 <!-- Non-TDD --> Update `Documents/Guides/TestCatalog.md` and `Documents/Guides/Test.md` to describe the restored binding coverage surface and any remaining explicit boundary cases. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label bindings-gap-closure -TimeoutMs 180000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Bindings." -Label bindings-gap-closure-final -TimeoutMs 600000`.
