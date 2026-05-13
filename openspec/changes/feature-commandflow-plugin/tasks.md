## 1. Reference And Plugin Boundary

- [ ] 1.1 <!-- Non-TDD --> Inspect the upstream GenericMessagePlugin/GMP GitHub repository for `XConsoleManager.h`, `XConsoleManager.cpp`, `XConsolePythonSupport.h`, and any related registration/commandlet files; record the repository URL, revision, and relevant files in the `CommandFlow` design notes or README, then verify the note is present with `rg -n "GenericMessagePlugin|XConsole|revision" Plugins\CommandFlow openspec\changes\feature-commandflow-plugin`.
- [ ] 1.2 <!-- Non-TDD --> Create `Plugins\CommandFlow\CommandFlow.uplugin` with `CommandFlowRuntime` and `CommandFlowAutomation` modules, no HTTP/Python remote modules, and no UnrealEvent dependency; verify descriptor JSON with `Get-Content -Raw Plugins\CommandFlow\CommandFlow.uplugin | ConvertFrom-Json`.
- [ ] 1.3 <!-- Non-TDD --> Add minimal module scaffolding and build files under `Plugins\CommandFlow\Source\CommandFlowRuntime\` and `Plugins\CommandFlow\Source\CommandFlowAutomation\`; verify compile discovery with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label commandflow-scaffold -TimeoutMs 180000 -NoXGE`.

## 2. Runtime Command SDK

- [ ] 2.1 <!-- TDD --> Add runtime tests for command registration metadata, command list queries, help text, and parameter metadata under the new CommandFlow test scope; observe failing tests with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Runtime." -Label commandflow-runtime-red -TimeoutMs 600000`.
- [ ] 2.2 <!-- TDD --> Implement `CommandFlowRuntime` command registry, metadata storage, and typed registration API until the metadata tests pass; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Runtime." -Label commandflow-runtime-registry -TimeoutMs 600000`.
- [ ] 2.3 <!-- TDD --> Add positive and negative runtime tests for argument conversion of the v1 supported parameter set, including invalid argument diagnostics; observe failing tests with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Runtime.Arguments" -Label commandflow-args-red -TimeoutMs 600000`.
- [ ] 2.4 <!-- TDD --> Implement argument parsing/conversion and explicit command result reporting until positive and negative argument tests pass; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Runtime.Arguments" -Label commandflow-args -TimeoutMs 600000`.
- [ ] 2.5 <!-- TDD --> Add tests for execution context output sinks, integer/string result values, and failure propagation; implement the context/result model and verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Runtime.Context" -Label commandflow-context -TimeoutMs 600000`.

## 3. Automation Runner

- [ ] 3.1 <!-- TDD --> Add automation runner tests for command file parsing, ordered execution, malformed command diagnostics, and failure-policy behavior; observe failing tests with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Automation.FileRunner" -Label commandflow-file-runner-red -TimeoutMs 600000`.
- [ ] 3.2 <!-- TDD --> Implement the command file runner and summary result output until file runner tests pass; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Automation.FileRunner" -Label commandflow-file-runner -TimeoutMs 600000`.
- [ ] 3.3 <!-- TDD --> Add automation tests for pipeline pause/continue, resumed execution order, and mismatched continue failures; implement pipeline state handling and verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow.TestModule.Automation.Pipeline" -Label commandflow-pipeline -TimeoutMs 600000`.
- [ ] 3.4 <!-- TDD --> Add commandlet/headless runner tests or compile checks for `CommandFlowAutomation` entry points, then implement the commandlet/file execution entry if included in v1; verify with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label commandflow-automation-commandlet -TimeoutMs 180000 -NoXGE`.

## 4. Boundaries And Documentation

- [ ] 4.1 <!-- Non-TDD --> Document `CommandFlow` purpose, module boundaries, supported v1 argument types, excluded HTTP/Python/remote surfaces, and GMP `XConsole` reference source in `Plugins\CommandFlow\README.md`; verify required topics with `rg -n "CommandFlowRuntime|CommandFlowAutomation|HTTP|Python|XConsole|GenericMessagePlugin" Plugins\CommandFlow\README.md`.
- [ ] 4.2 <!-- Non-TDD --> Confirm `CommandFlowRuntime` and `CommandFlowAutomation` do not depend on `UnrealEvent`, `AngelscriptRuntime`, `HTTPServer`, or `PythonScriptPlugin`; verify with `rg -n "UnrealEvent|AngelscriptRuntime|HTTPServer|PythonScriptPlugin" Plugins\CommandFlow\Source`.
- [ ] 4.3 <!-- Non-TDD --> Record a follow-up note for later UnrealEvent pruning that GMP `XConsoleManager`, `XConsolePythonSupport`, HTTP/Python XConsole dependencies, and `z.*` pipeline commands can be removed only after UnrealEvent diagnostics/tests migrate or are deliberately dropped; verify the note with `rg -n "XConsoleManager|XConsolePythonSupport|z\\.\\*|CommandFlow" openspec Plugins\CommandFlow`.

## 5. Final Verification

- [ ] 5.1 <!-- Non-TDD --> Run a CommandFlow-focused build with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label commandflow-final -TimeoutMs 180000 -NoXGE`.
- [ ] 5.2 <!-- Non-TDD --> Run the CommandFlow runtime and automation test prefixes with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "CommandFlow." -Label commandflow-final -TimeoutMs 600000`.
- [ ] 5.3 <!-- Non-TDD --> Validate this OpenSpec change with `openspec validate "feature-commandflow-plugin" --strict --json`.
