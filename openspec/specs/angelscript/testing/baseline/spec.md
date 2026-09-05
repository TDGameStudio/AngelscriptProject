# Testing Baseline

## Purpose

Define the compile-time boundary between the preserved legacy test corpus and the replacement Automation suite used by new language work.

## Requirements

### Requirement: Legacy and replacement tests use separate compile gates

The system SHALL treat `WITH_ANGELSCRIPT_UNITTESTS` as the legacy-suite gate with a default value of `0` and `WITH_ANGELSCRIPT_TESTS` as the replacement-suite gate with a default value of `1`.

#### Scenario: Default editor build excludes the legacy corpus
- **GIVEN** the checked-in default compile options
  > Inputs: `WITH_ANGELSCRIPT_UNITTESTS=0` is the default legacy policy and `WITH_ANGELSCRIPT_TESTS=1` independently enables replacement sources.
- **WHEN** the host editor target is built
  > Details: Discovery evaluates source-free `.ubtignore` boundaries before compiling test translation units.
- **THEN** complete legacy test translation units, including their includes and static registration objects, are excluded beneath source-free `.ubtignore`-marked `Legacy/` parents
  > Observables: Legacy source does not enter compilation or static Automation registration.
- **AND** `WITH_ANGELSCRIPT_UNITTESTS=0` remains the legacy policy gate for the active module shells and dependency declarations
  > Boundaries: The macro controls the retained shell surface; it does not rename or delete the quarantined corpus.
- **AND** the UE test-module shells remain loadable
  > Observables: Module discovery succeeds without activating the legacy framework.

#### Scenario: Default editor build includes replacement tests
- **GIVEN** the checked-in default compile options
  > Inputs: The replacement gate has the default value `WITH_ANGELSCRIPT_TESTS=1`.
- **WHEN** the host editor target is built
  > Details: Replacement sources are evaluated independently from the legacy gate.
- **THEN** replacement test translation units are enabled by `WITH_ANGELSCRIPT_TESTS=1`
  > Observables: NewVersion Automation registrations remain discoverable in the default editor build.

#### Scenario: Default test module excludes the legacy framework surface
- **GIVEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
  > Context: The module shell is preserved while the old framework implementation is quarantined.
- **WHEN** the `AngelscriptTest` module is compiled and loaded
  > Inputs: Compile-time includes, startup ownership, and module dependencies all honor the same legacy gate.
- **THEN** legacy CQTest force includes, engine-pool startup, legacy framework headers, and legacy-only module dependencies are excluded
  > Observables: No legacy framework bootstrap or fixture pool becomes active.
- **AND** only the module shell and replacement sources remain active
  > Boundaries: Preserved legacy files remain reference material, not active compilation inputs.

### Requirement: Replacement tests use their final public identity

The system SHALL register new C++ Automation tests beneath `Angelscript.UnitTest.<Area>.<Scenario>` without exposing their temporary physical source directory in public test names, types, or capability identities.

#### Scenario: Isolated baseline is discoverable
- **WHEN** UE Automation discovers the replacement baseline test
  > Inputs: Discovery uses the public Automation name rather than the physical NewVersion directory.
- **THEN** it is addressable through the `Angelscript.UnitTest.Baseline` prefix and passes without legacy CQTest helpers or legacy engine-pool fixtures
  > Observables: The baseline appears under its final public identity and has no dependency on quarantined framework services.

  Example: the public identity is `Angelscript.UnitTest.Baseline`.

#### Scenario: NativeEngine CQTests use one stable prefix
- **WHEN** a replacement CQTest exercises the reconstructed native AngelScript frontend
  > Inputs: CQTest's directory is `Angelscript.UnitTest.NativeEngine`, the test class identifier supplies the exact frontend area token, and its methods name individual observable scenarios.
- **THEN** Unreal Automation exposes it beneath `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>`
  > Observables: The public name is independent of the temporary `NewVersion` directory and of any future physical source reorganization.
- **BUT** no replacement test registers beneath a legacy public prefix
  > Boundaries: `Angelscript.TestModule`, `Angelscript.CppTests`, and `Angelscript.Editor` remain absent in the default reconstruction baseline.

#### Scenario: Legacy Automation prefixes are absent by default
- **GIVEN** the checked-in default compile options
  > Inputs: Legacy compilation is disabled while replacement compilation remains enabled.
- **WHEN** UE Automation enumerates registered tests
  > Details: Registration names are evaluated after all enabled test translation units load.
- **THEN** no test is registered beneath `Angelscript.TestModule`, `Angelscript.CppTests`, or `Angelscript.Editor`
  > Observables: The legacy public namespaces have zero discoverable registrations in the default baseline.

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

### Requirement: Legacy test source remains available in isolated reference trees

The system SHALL preserve the legacy test files beneath `Legacy/` parents owned by their existing modules while excluding those complete subtrees from normal UBT and UHT discovery.

#### Scenario: Isolation preserves the old corpus without content rewrites
- **WHEN** the replacement baseline is established
  > Inputs: Existing legacy files move only within their owning module's source tree.
- **THEN** existing legacy test source is relocated beneath its owning module's ignored `Legacy/` parent for reference
  > Observables: The quarantined files remain readable and keep their original implementation content.
- **AND** old source content is not mechanically rewritten merely to disable compilation
  > Boundaries: Relocation and discovery exclusion provide isolation; mass source edits are not part of that boundary.
- **BUT** generated JIT artifacts are not mechanically rewritten solely to enforce test isolation
  > Boundaries: Generated output is preserved unless a separate generator-owned behavior requires a change.
- **AND** passive TestJIT probe symbols required by retained generated objects may remain compiled while provider registration is dormant
  > Details: Passive link compatibility does not grant provider startup authority.

#### Scenario: Reflected legacy fixtures are excluded consistently
- **GIVEN** old test headers contain Unreal reflection macros
  > Context: Excluding only `.cpp` files would leave UHT with an inconsistent legacy input surface.
- **WHEN** the legacy subtree is isolated
  > Inputs: The source-free parent `.ubtignore` covers both implementation files and reflected headers.
- **THEN** those headers are excluded through the source-free parent `.ubtignore` boundary rather than a custom preprocessor block
  > Observables: UHT and UBT observe the same excluded subtree.
- **AND** old translation units and UHT inputs are excluded together
  > Verification: Discovery evidence shows neither source category enters the default target.

#### Scenario: Source topology transition is rebuilt from fresh discovery
- **GIVEN** a `.ubtignore` boundary or legacy source location has changed
  > Context: Cached UBT discovery may otherwise describe the pre-isolation source topology.
- **WHEN** the transition build is verified
  > Inputs: Verification invalidates or bypasses the existing makefile cache for the topology transition.
- **THEN** the UBT makefile cache is bypassed or explicitly regenerated
  > Observables: The build evaluates the current ignored-source boundary rather than stale discovery state.
- **AND** a later ordinary incremental build remains valid
  > Verification: Fresh-discovery success is followed by an incremental-build proof for the same topology.

### Requirement: Focused replacement verification uses the Harness Fast profile

The project SHALL run focused replacement Automation tests through Harness `ue.test` with `Fast = $true` and the narrowest exact public prefix when rendering is not part of the behavior under test.

#### Scenario: A logic-only replacement test is verified
- **GIVEN** a replacement test that does not require rendering
  > Context: Headless commandlet-style startup is sufficient for its observable behavior.
- **WHEN** the test is selected for focused verification
  > Inputs: The exact `Angelscript.UnitTest.<Area>.<Scenario>` prefix and `Fast = $true` bound the run.
- **THEN** Harness launches `UnrealEditor-Cmd.exe` with `Fast = $true`
  > Observables: The fast route avoids rendering-dependent editor startup while retaining the selected Automation test.
- **AND** preserves Automation report, timeout, workspace-isolation, and process-exit validation
  > Verification: Success requires both Automation result evidence and a valid process outcome.

#### Scenario: Startup duration is reported as evidence
- **WHEN** the isolation baseline is completed
  > Inputs: Ordinary and Fast `ue.test` runs select the same focused public baseline on the same environment.
- **THEN** ordinary and Fast Harness `ue.test` process durations for the same focused baseline are recorded
  > Observables: Evidence identifies mode, exact test prefix, process duration, and environment context for each run.

  | Comparison field | Required interpretation |
  |---|---|
  | Test selection | Same focused baseline |
  | Launch mode | Ordinary versus Fast |
  | Duration | Observed process time, not a correctness oracle |
- **AND** the timing is treated as environment-specific evidence rather than a portable correctness threshold
  > Boundaries: No fixed cross-machine performance requirement is inferred from the two observations.
