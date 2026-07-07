## ADDED Requirements

### Requirement: Editor navigation coverage SHALL remain explicit and runnable
The editor navigation surface SHALL have explicit automation coverage for the source-navigation behavior that is currently represented by the lone editor test file.

#### Scenario: Source navigation cases are represented by explicit assertions
- **WHEN** `Plugins/Angelscript/Source/AngelscriptTest/Editor/AngelscriptSourceNavigationTests.cpp` is run after this change is applied
- **THEN** the existing navigation cases remain explicit and runnable, and any unsupported headless behavior is stated as a concrete boundary

#### Scenario: Editor test layer stays discoverable
- **WHEN** the automation framework scans the editor-facing tests after this change is applied
- **THEN** the editor navigation cases remain discoverable under the existing `Angelscript.TestModule.Editor.*` family

### Requirement: Networking coverage SHALL exercise the RPC compilation surface
The networking theme SHALL continue to provide explicit coverage for RPC-related compile-time behavior.

#### Scenario: RPC compile cases remain explicit
- **WHEN** `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkRPCTests.cpp` is run after this change is applied
- **THEN** the Server, Client, Multicast, Validation, Unreliable, and mixed RPC cases remain explicit and runnable as compile-time contract tests

#### Scenario: Networking prefix remains stable
- **WHEN** the automation framework scans the networking suite after this change is applied
- **THEN** the tests remain discoverable under `Angelscript.TestModule.Networking.*`

### Requirement: Dump coverage SHALL exercise state export and report generation
The dump theme SHALL continue to validate state export and report generation behavior with explicit assertions.

#### Scenario: DumpAll coverage remains explicit
- **WHEN** `Plugins/Angelscript/Source/AngelscriptTest/Dump/AngelscriptDumpTests.cpp` is run after this change is applied
- **THEN** the CSV writer, dump export, summary, and end-to-end dump behaviors are all represented by explicit assertions

#### Scenario: Dump output remains under the existing dump prefix
- **WHEN** the automation framework scans the dump suite after this change is applied
- **THEN** the dump tests remain discoverable under `Angelscript.TestModule.Dump.*`

### Requirement: Thin diagnostics-adjacent themes SHALL have an explicit first-wave coverage baseline
The performance, memory, GC, and validation themes SHALL have a first-wave coverage baseline that makes the important boundaries visible without requiring a full suite rewrite.

#### Scenario: Performance themes retain explicit baseline assertions
- **WHEN** the performance tests are run after this change is applied
- **THEN** the microbenchmark and reflective fallback benchmark themes retain explicit baseline assertions for their current measured behaviors

#### Scenario: Memory, GC, and validation themes retain explicit baseline assertions
- **WHEN** the memory, GC, and validation tests are run after this change is applied
- **THEN** the cycle-bound, lifecycle, and macro-validation cases remain explicit and runnable

### Requirement: Thin-theme coverage SHALL be reflected in project documentation
The project documentation SHALL describe the first-wave coverage baseline for the thin editor and diagnostics themes.

#### Scenario: Catalog shows the thin-theme coverage baseline
- **WHEN** `Documents/Guides/TestCatalog.md` is inspected after this change is applied
- **THEN** it reflects the first-wave baseline for the editor, networking, dump, performance, memory, GC, and validation themes

#### Scenario: Test guide shows the verification entry points
- **WHEN** `Documents/Guides/Test.md` is inspected after this change is applied
- **THEN** it includes the prefix-based verification commands used to validate the thin-theme coverage

## Testing Requirements

- **Target test layer**: UE Functional / Runtime Integration / Editor themed tests under `Plugins/Angelscript/Source/AngelscriptTest/`.
- **Expected Automation prefix**:
  - `Angelscript.TestModule.Editor.*`
  - `Angelscript.TestModule.Networking.*`
  - `Angelscript.TestModule.Dump.*`
  - `Angelscript.TestModule.Performance.*`
  - `Angelscript.TestModule.Memory.*`
  - `Angelscript.TestModule.GC.*`
  - `Angelscript.TestModule.Validation.*`
- **Recommended helper / harness**: existing theme-specific helpers, `Shared/AngelscriptTestUtilities.h`, `Shared/AngelscriptTestWorld.h` where object lifecycle is needed, and the current CQTest / automation test harness already used by each file.
- **Verification entry point command**:
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Editor." -Label editor-diagnostics-editor -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Networking." -Label editor-diagnostics-networking -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Dump." -Label editor-diagnostics-dump -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Performance." -Label editor-diagnostics-performance -TimeoutMs 900000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Memory." -Label editor-diagnostics-memory -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.GC." -Label editor-diagnostics-gc -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Validation." -Label editor-diagnostics-validation -TimeoutMs 600000`
  - `powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label editor-diagnostics-coverage -TimeoutMs 180000`

The scoped theme-prefix runs above are the verification gate for this change. The broad `Angelscript.TestModule.` prefix is not required here because it pulls unrelated failures into the change scope.
