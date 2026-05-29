## 1. Build Runner Implementation

- [ ] 1.1 <!-- TDD --> Add engine-layout detection coverage for precompiled, source-layout, and invalid engines.
  - Scope: `Tools\Shared\UnrealCommandUtils.ps1` and the selected tooling-test location.
  - Expected change: the resolver can distinguish a ready `UnrealBuildTool.dll`, a source tree with `UnrealBuildTool.csproj`, and an unusable engine root without requiring a real engine checkout.
  - Tests to add: mock filesystem tests for all three layout states, including the source-layout case where the DLL is absent but the UBT project exists.
  - Verification: run the new tooling test script directly from PowerShell.

- [ ] 1.2 <!-- TDD --> Add runner-mode coverage for source-layout engine serialization behavior.
  - Scope: `Tools\RunBuild.ps1`, `Tools\Shared\UnrealCommandUtils.ps1`, and tooling tests.
  - Expected change: source-layout mode records a distinct build mode and acquires the engine-level lock before launching the source-layout build path, while precompiled mode keeps the current concurrent path.
  - Tests to add: dry-run or mocked process-launch coverage proving source-layout mode forces engine serialization and precompiled mode does not.
  - Verification: run the new tooling test script directly from PowerShell.

- [ ] 1.3 <!-- Non-TDD --> Implement the source-layout build adapter behind `Tools\RunBuild.ps1`.
  - Scope: `Tools\RunBuild.ps1` and shared process/logging utilities as needed.
  - Expected change: the public build command remains `Tools\RunBuild.ps1`, but source-layout engines can bootstrap UBT and build the configured target without users manually invoking engine batch commands.
  - Verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label source-layout-smoke -TimeoutMs 3600000 -SerializeByEngine`.

## 2. Documentation and Validation

- [ ] 2.1 <!-- Non-TDD --> Update build documentation for source-layout engines.
  - Scope: `Documents\Guides\Build.md`.
  - Expected change: the guide explains that `Tools\RunBuild.ps1` supports both precompiled and source-layout engine roots, source-layout mode may bootstrap UBT, and local engine paths stay in `AgentConfig.ini`.
  - Verification: review the document for absence of machine-local paths and absence of daily direct engine-batch instructions.

- [ ] 2.2 <!-- Non-TDD --> Validate the planned source-layout path on a real source-layout engine when available.
  - Scope: build runner behavior and generated `Saved\Build\<Label>\<RunId>\` artifacts.
  - Expected change: a clean run produces `Build.log`, `UBT.log` when applicable, `RunMetadata.json`, and a zero final exit code for the configured editor target.
  - Verification: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label source-layout-real -TimeoutMs 3600000 -SerializeByEngine`.