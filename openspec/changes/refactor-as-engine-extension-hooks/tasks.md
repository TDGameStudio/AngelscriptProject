## 1. Runtime extension seam

- [x] 1.1 <!-- TDD --> Add the extension registry and interface under `Plugins/Angelscript/Source/AngelscriptRuntime/Core/` and create tests that prove empty-registry no-op behavior, late registration replay, and unregister semantics. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Extension" -Label as-engine-extension-registry-1 -TimeoutMs 900000`.
- [x] 1.2 <!-- TDD --> Wire `FAngelscriptEngine` and `FAngelscriptRuntimeModule` lifecycle transitions to the registry so registered extensions are attached to active engines and detached on shutdown. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-engine-extension-registry-2 -TimeoutMs 900000 -NoXGE`.

## 2. Validation

- [x] 2.1 <!-- Non-TDD --> Run the targeted extension tests and a full build to confirm the new seam is behavior-preserving when unused. Verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.Engine.Extension" -Label as-engine-extension-registry-3 -TimeoutMs 900000` and `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-engine-extension-registry-4 -TimeoutMs 1800000`.
- [x] 2.2 <!-- Non-TDD --> Run `openspec validate refactor-as-engine-extension-hooks --strict --json` from the project root and confirm the change is ready for implementation.
