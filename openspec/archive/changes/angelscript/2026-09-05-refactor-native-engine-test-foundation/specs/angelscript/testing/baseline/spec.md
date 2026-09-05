## MODIFIED Requirements

### Requirement: Replacement tests use their final public identity

The system SHALL register new C++ Automation tests beneath `Angelscript.UnitTest.<Area>.<Scenario>` without exposing their temporary physical source directory in public test names, types, or capability identities.

#### Scenario: NativeEngine CQTests use one stable prefix
- **WHEN** a replacement CQTest exercises the reconstructed native AngelScript frontend
  > Inputs: CQTest's directory is `Angelscript.UnitTest.NativeEngine`, the test class identifier supplies the exact frontend area token, and its methods name individual observable scenarios.
- **THEN** Unreal Automation exposes it beneath `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>`
  > Observables: The public name is independent of the temporary `NewVersion` directory and of any future physical source reorganization.
- **BUT** no replacement test registers beneath a legacy public prefix
  > Boundaries: `Angelscript.TestModule`, `Angelscript.CppTests`, and `Angelscript.Editor` remain absent in the default reconstruction baseline.

## ADDED Requirements

### Requirement: NativeEngine tests own an isolated CQTest foundation

The system SHALL make CQTest available to replacement NativeEngine tests under `WITH_ANGELSCRIPT_TESTS` without reactivating any legacy AngelScript test framework surface.

#### Scenario: Replacement CQTest compiles under the replacement gate
- **GIVEN** the checked-in reconstruction compile policy
  > Inputs: `WITH_ANGELSCRIPT_TESTS=1` and `WITH_ANGELSCRIPT_UNITTESTS=0`.
- **WHEN** the `AngelscriptTest` module builds a test beneath `NewVersion/NativeEngine`
- **THEN** the test can use CQTest registration and matcher assertions
  > Observables:
  >
  > - `CQTest` is an explicit replacement-test dependency.
  > - No legacy force include is required.
  > - The test translation unit is discovered outside every ignored `Legacy/` subtree.
- **BUT** legacy helpers, engine-pool startup, and legacy-only dependencies remain excluded
  > Boundaries: Enabling CQTest as a UE testing library does not enable the quarantined AngelScript test framework.

#### Scenario: NativeEngine fixtures are frontend-local
- **WHEN** a NativeEngine test creates inputs and captures results
  > Details: Fixtures may own source snapshots, diagnostics, frontend options, and compilation sessions introduced by later Changes.
- **THEN** their ownership and cleanup are local to the replacement test class or replacement-only support code
- **AND** no fixture obtains a mutable ambient `asCScriptEngine` or `FAngelscriptEngine`
  > Verification: The foundation tests compile and execute with the legacy runtime still dormant.

#### Scenario: Focused feedback uses one managed process
- **WHEN** one NativeEngine area is verified after an incremental editor build
  > Inputs: The narrowest stable `Angelscript.UnitTest.NativeEngine.<Area>` prefix and `Fast = $true`.
- **THEN** all scenarios for that area execute in one Harness-managed Unreal process
  > Observables: The result retains Automation report, process exit, timeout, and workspace evidence.
- **BUT** process duration is not a portable correctness threshold
  > Boundaries: The measured approximately 26.8-second startup floor is environment evidence used to group tests, not a cross-machine performance requirement.
