## 1. Import the project-owned extension

- [x] 1.1 <!-- Non-TDD --> Copy the Hazelight VS Code extension source from `Reference/vscode-unreal-angelscript/` into tracked `Extensions/AngelscriptVSCode/` without nested Git metadata or generated dependencies.
- [x] 1.2 <!-- Non-TDD --> Update extension publisher, repository, README, and build metadata to identify the TDGameStudio-maintained variant.
- [x] 1.3 <!-- Non-TDD --> Add the extension build/install commands to the project guide.

## 2. Record and contract test

- [x] 2.1 <!-- TDD --> Add a Hazelight Language Server field-order decoder to `AngelscriptDebuggerDatabaseTests.cpp` and assert the current payload fails with the expected reader error. Verify with `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger.Database" -Label vscode-lsp-red-rebuilt -TimeoutMs 900000`.

## 3. Runtime protocol compatibility

- [x] 3.1 <!-- TDD --> Add reserved compatibility slots to `FAngelscriptDebugDatabaseSettings` without restoring Haze semantics.
- [x] 3.2 <!-- TDD --> Emit version 7 and serialize the complete Hazelight field order with deterministic false compatibility values.
- [x] 3.3 <!-- TDD --> Update debugger database assertions for the compatibility slots and verify the focused test passes.

## 4. Documentation and verification

- [x] 4.1 <!-- Non-TDD --> Add the project VS Code Angelscript integration guide, including workspace root, port, supported features, and the StopPIE limitation.
- [x] 4.2 <!-- Non-TDD --> Verify active source contains no `WITH_ANGELSCRIPT_HAZE` references and no `bUseAngelscriptHaze` member.
- [x] 4.3 <!-- TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger.Database" -Label vscode-lsp-green -TimeoutMs 900000`.
- [x] 4.4 <!-- TDD --> Run `Tools\RunBuild.ps1 -Label vscode-lsp-green-build -TimeoutMs 900000`.
- [x] 4.5 <!-- Non-TDD --> Run the owned extension compile/package command from `Extensions/AngelscriptVSCode/` and verify the VSIX output.
