## ADDED Requirements

### Requirement: Full suite groups match registered automation prefixes

The `All` suite SHALL select each current automation test family through a
prefix that matches registered tests and SHALL not duplicate a family solely
because of obsolete category names.

#### Scenario: Generator family runs once
- **WHEN** the `All` suite reaches the generated-class test family
- **THEN** it runs the current `Angelscript.TestModule.Generator` registrations
- **AND** it does not report obsolete `ClassGenerator` or `ScriptClass` groups
with no matching tests

### Requirement: Tests can explicitly suppress ambient engine resolution

Automation tests that exercise a no-current-engine branch SHALL use a scoped
test-only suppression rather than mutating the Editor-owned primary subsystem.

#### Scenario: Suppressed test resolver reports no engine
- **WHEN** a supported automation test enters the no-engine resolver scope
- **THEN** current-engine lookup and initialization checks report no resolved
engine for that scope
- **AND** leaving the scope restores normal scoped/subsystem resolution

### Requirement: Builder diagnostics do not retain deleted enum descriptions

The AngelScript builder SHALL not expose a deleted enum-value global
description through post-build diagnostic enumeration.

#### Scenario: Enum build completes before diagnostics inspect globals
- **WHEN** an SDK test compiles a module containing enum values and then
enumerates builder global descriptions
- **THEN** the enumeration completes without dereferencing a deleted description
- **AND** it reports only descriptions that remain valid after compilation

### Requirement: Binding exception fixtures assert current source locations

Binding tests that assert a script exception stack SHALL keep their expected
source coordinates synchronized with the embedded fixture text.

#### Scenario: Null receiver produces the current fixture stack
- **WHEN** the Widget or World function-library null-receiver fixture throws a
script exception
- **THEN** the test accepts the emitted function declarations, line numbers,
and columns for that fixture's current source text

### Requirement: Editor compile settings registration is deterministic

The editor module SHALL register the Angelscript and Angelscript Compile
Options settings sections whenever its editor startup module runs.

#### Scenario: Settings module was not preloaded
- **WHEN** `AngelscriptEditor` starts before another editor feature has loaded
the Settings module
- **THEN** both Angelscript Project Settings sections are registered
- **AND** the compile-options section has its modification validator bound
