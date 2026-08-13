# uasfunction-dispatch-matrix-and-jit-paths Specification

## Purpose
TBD - created by archiving change test-uasfunction-dispatch-matrix-and-jit-paths. Update Purpose after archive.
## Requirements
### Requirement: UASFunction wrapper allocation is covered by representative matrix tests

The ASFunction test suite SHALL assert the generated `UASFunction` subclass selected for representative function shapes rather than only validating call results.

#### Scenario: Specialized non-thread-safe wrapper shapes are selected

- WHEN script class functions are generated for no-param, single primitive argument, reference argument, primitive return, and object return shapes
- THEN each generated function uses the expected specialized `UASFunction` wrapper class for its reflected ABI shape
- AND each wrapper can still execute the script behavior it represents

#### Scenario: Generic boundaries stay generic

- WHEN a generated function is thread-safe, static, virtual/non-final, multi-argument, or otherwise unsupported by a specialized wrapper
- THEN the generated function uses the appropriate generic `UASFunction` wrapper
- AND the test documents why the specialized non-virtual wrapper is not expected

### Requirement: StaticJIT AOT verifies UASFunction-backed JIT execution

The StaticJIT AOT tests SHALL prove generated JIT entries are reached through `UASFunction` dispatch for representative reflected script methods.

#### Scenario: UASFunction targets expose JIT entries

- WHEN the AOT fixture is loaded from generated precompiled data
- THEN the target script methods have non-null JIT entry pointers required by UASFunction dispatch
- AND the functions remain discoverable through the generated Unreal class/function metadata

#### Scenario: RuntimeCallEvent reaches generated JIT code

- WHEN a JIT-capable generated `UASFunction` is invoked through reflected parameter memory
- THEN a test-visible generated-code marker proves StaticJIT generated code ran
- AND primitive return values, primitive arguments, reference writeback, object return identity, and static/world-context-sensitive behavior match expected script semantics

### Requirement: JIT and non-JIT dispatch boundaries are explicit

Tests SHALL make the current JIT dispatch limitations visible so later runtime refactors can distinguish intentional behavior from missing coverage.

#### Scenario: Virtual override is not bypassed by JIT-capable paths

- WHEN a parent generated function is invoked on a child script object that overrides it
- THEN dispatch resolves the child override rather than blindly calling the parent raw JIT entry

#### Scenario: Thread-safe JIT behavior is documented

- WHEN a thread-safe generated function has JIT entries available
- THEN the test records whether the current wrapper uses generic context behavior or a direct JIT branch
- AND the observable result remains correct

### Requirement: Runtime JIT VMEntry-only boundaries remain explicit in UASFunction dispatch

The UASFunction/JIT dispatch matrix SHALL distinguish a Runtime VMEntry from Static AOT Raw/Parms entries. A Runtime-compiled function MUST NOT be treated as having direct reflected entry points that the backend did not publish, and reflected execution SHALL remain VM-correct.

#### Scenario: Runtime function has only VMEntry

- **WHEN** an eligible script function has a Runtime VMEntry but null Runtime Raw and Parms entries
- **THEN** script context execution may reach the Runtime VMEntry
- **AND** `UASFunction` dispatch that requires Raw or Parms continues through its current VM/context path
- **AND** return values and parameter writeback remain correct

#### Scenario: Runtime function is unsupported

- **WHEN** a reflected script function is outside the Runtime backend subset
- **THEN** the generated UASFunction wrapper and current virtual override routing remain unchanged
- **AND** execution falls back to the current VM Binding rather than calling a stale or partial Runtime entry

