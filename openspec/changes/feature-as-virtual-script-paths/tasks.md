## 1. OpenSpec Record

- [x] 1.1 <!-- Non-TDD --> Replace the stale `as://...` provider-registry plan with the v1 `/Angelscript/...` source identity plan.

## 2. Virtual Path Value Model

- [x] 2.1 <!-- TDD --> Add focused FileSystem tests for parsing `/Angelscript/Game`, `/Angelscript/Plugin`, `/Angelscript/Memory/Immediate`, invalid path rejection, full virtual path preservation, and module-name derivation.
- [x] 2.2 <!-- TDD --> Implement `FAngelscriptVirtualScriptPath` and `FAngelscriptScriptSource` under `AngelscriptRuntime/Core`.

## 3. Preprocessor Integration

- [x] 3.1 <!-- TDD --> Add Preprocessor tests proving `AddFile()` emits `/Angelscript/Game/...` metadata and `AddSource()` can preprocess memory text with no physical file.
- [x] 3.2 <!-- TDD --> Implement descriptor-aware `FAngelscriptPreprocessor::AddSource()` and add `VirtualPath` to file summaries and module code sections.

## 4. Engine Discovery And Compile Support

- [x] 4.1 <!-- TDD --> Add FileSystem tests proving source descriptor enumeration preserves project/plugin disk discovery and produces canonical full virtual paths.
- [x] 4.2 <!-- TDD --> Add descriptor-aware engine discovery APIs while preserving `FindAllScriptFilenames()`.
- [x] 4.3 <!-- TDD --> Add Compiler tests proving memory-backed sources compile and use virtual path section identity.
- [x] 4.4 <!-- TDD --> Add a runtime/test helper path for compiling descriptor-backed memory sources.

## 5. Documentation And Validation

- [x] 5.1 <!-- Non-TDD --> Update targeted documentation/comments that still describe virtual AS paths as `as://...`.
- [x] 5.2 <!-- Non-TDD --> Run focused tests:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.FileSystem.VirtualScriptPaths" -Label virtual-script-paths-filesystem-final -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Preprocessor.VirtualScriptPaths" -Label virtual-script-paths-preprocessor-final -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Compiler.VirtualScriptPaths" -Label virtual-script-paths-compiler-final -TimeoutMs 600000`
- [x] 5.3 <!-- Non-TDD --> Run build and OpenSpec validation:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label virtual-script-paths-build -TimeoutMs 180000`
  - `openspec validate "feature-as-virtual-script-paths" --strict --json`

## 6. Review Hardening

- [x] 6.1 <!-- TDD --> Reject trailing-slash virtual paths as empty path segments.
- [x] 6.2 <!-- TDD --> Fail closed when `FAngelscriptPreprocessor::AddSource()` receives an invalid source descriptor.
- [x] 6.3 <!-- TDD --> Preserve plugin virtual paths in editor directory watcher reload queues and loaded-section folder deletion enumeration.
- [x] 6.4 <!-- TDD --> Preserve legacy `AllRootPaths` override behavior when `AllScriptRoots` descriptors are stale.
- [x] 6.5 <!-- Non-TDD --> Remove the stale `as-engine-extension-registry` spec delta from this v1 source-identity change.
