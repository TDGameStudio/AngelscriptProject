## Purpose

Define the compile-time boundary between the preserved legacy test corpus and the replacement Automation suite used by new language work.

## ADDED Requirements

### Requirement: Legacy and replacement tests use separate compile gates

The system SHALL treat `WITH_ANGELSCRIPT_UNITTESTS` as the legacy-suite gate with a default value of `0` and `WITH_ANGELSCRIPT_TESTS` as the replacement-suite gate with a default value of `1`.

#### Scenario: Default editor build excludes the legacy corpus
- **GIVEN** the checked-in default compile options
- **WHEN** the host editor target is built
- **THEN** complete legacy test translation units, including their includes and static registration objects, are excluded beneath source-free `.ubtignore`-marked `Legacy/` parents
- **AND** `WITH_ANGELSCRIPT_UNITTESTS=0` remains the legacy policy gate for the active module shells and dependency declarations
- **AND** the UE test-module shells remain loadable

#### Scenario: Default editor build includes replacement tests
- **GIVEN** the checked-in default compile options
- **WHEN** the host editor target is built
- **THEN** replacement test translation units are enabled by `WITH_ANGELSCRIPT_TESTS=1`

#### Scenario: Default test module excludes the legacy framework surface
- **GIVEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **WHEN** the `AngelscriptTest` module is compiled and loaded
- **THEN** legacy CQTest force includes, engine-pool startup, legacy framework headers, and legacy-only module dependencies are excluded
- **AND** only the module shell and replacement sources remain active

### Requirement: Replacement tests use their final public identity

The system SHALL register new C++ Automation tests beneath `Angelscript.UnitTest.<Area>.<Scenario>` without exposing their temporary physical source directory in public test names, types, or capability identities.

#### Scenario: Isolated baseline is discoverable
- **WHEN** UE Automation discovers the replacement baseline test
- **THEN** it is addressable through the `Angelscript.UnitTest.Baseline` prefix and passes without legacy CQTest helpers or legacy engine-pool fixtures

#### Scenario: Legacy Automation prefixes are absent by default
- **GIVEN** the checked-in default compile options
- **WHEN** UE Automation enumerates registered tests
- **THEN** no test is registered beneath `Angelscript.TestModule`, `Angelscript.CppTests`, or `Angelscript.Editor`

### Requirement: Legacy test source remains available in isolated reference trees

The system SHALL preserve the legacy test files beneath `Legacy/` parents owned by their existing modules while excluding those complete subtrees from normal UBT and UHT discovery.

#### Scenario: Isolation preserves the old corpus without content rewrites
- **WHEN** the replacement baseline is established
- **THEN** existing legacy test source is relocated beneath its owning module's ignored `Legacy/` parent for reference
- **AND** old source content is not mechanically rewritten merely to disable compilation
- **BUT** generated JIT artifacts are not mechanically rewritten solely to enforce test isolation
- **AND** passive TestJIT probe symbols required by retained generated objects may remain compiled while provider registration is dormant

#### Scenario: Reflected legacy fixtures are excluded consistently
- **GIVEN** old test headers contain Unreal reflection macros
- **WHEN** the legacy subtree is isolated
- **THEN** those headers are excluded through the source-free parent `.ubtignore` boundary rather than a custom preprocessor block
- **AND** old translation units and UHT inputs are excluded together

#### Scenario: Source topology transition is rebuilt from fresh discovery
- **GIVEN** a `.ubtignore` boundary or legacy source location has changed
- **WHEN** the transition build is verified
- **THEN** the UBT makefile cache is bypassed or explicitly regenerated
- **AND** a later ordinary incremental build remains valid

### Requirement: Focused replacement verification uses the Harness Fast profile

The project SHALL run focused replacement Automation tests through Harness `ue.test` with `Fast = $true` and the narrowest exact public prefix when rendering is not part of the behavior under test.

#### Scenario: A logic-only replacement test is verified
- **GIVEN** a replacement test that does not require rendering
- **WHEN** the test is selected for focused verification
- **THEN** Harness launches `UnrealEditor-Cmd.exe` with `Fast = $true`
- **AND** preserves Automation report, timeout, workspace-isolation, and process-exit validation

#### Scenario: Startup duration is reported as evidence
- **WHEN** the isolation baseline is completed
- **THEN** ordinary and Fast Harness `ue.test` process durations for the same focused baseline are recorded
- **AND** the timing is treated as environment-specific evidence rather than a portable correctness threshold
