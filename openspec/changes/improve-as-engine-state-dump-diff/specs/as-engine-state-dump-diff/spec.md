## ADDED Requirements

### Requirement: Engine state snapshot covers full diagnostic engine state

The runtime SHALL provide a diagnostic snapshot capability that captures `FAngelscriptEngine` state and the underlying AngelScript VM/module internals into stable value rows without mutating the engine.

#### Scenario: Snapshot captures FAS engine state

- **WHEN** a snapshot is captured from an initialized `FAngelscriptEngine`
- **THEN** the snapshot SHALL include lifecycle flags, runtime config values, script root paths, package/settings/world-context observations, active module summaries, diagnostics summaries, hot-reload summaries, service presence rows, static-name cache rows, script enum lookup rows, and bound Blueprint event argument specialization rows
- **AND** private engine containers SHALL be represented as stable values, counts, names, paths, or explicit unavailable markers rather than mutable references

#### Scenario: Snapshot captures AngelScript engine internals

- **WHEN** a snapshot is captured from an engine with an active `asCScriptEngine`
- **THEN** the snapshot SHALL include low-level AS engine rows for registered types, typedefs, enums, global properties, global functions, funcdefs, template/list types, all registered/script declarations, imported functions, script modules, build/defer flags, script sections, type-id map entries, message callback state, and garbage collector statistics where those values are available in the current build

#### Scenario: Snapshot captures AngelScript module internals

- **WHEN** a snapshot is captured from an engine with one or more AS modules
- **THEN** the snapshot SHALL include low-level module rows for module name/base name, access mask/default namespace, script functions, global functions, imported bind information, template instances, script globals, global initialization state, breakpoint/discard state, local types, imported modules, module dependencies, class/enum/typedef/funcdef lists, external declarations, and reload state

### Requirement: Snapshot capture is side-effect free

The snapshot capability SHALL observe live state without triggering compile, reload, module discard, diagnostic emission, hot-reload queue mutation, or engine initialization.

#### Scenario: Capture preserves module state

- **WHEN** a caller captures a snapshot before and after reading active modules
- **THEN** the active module set SHALL remain unchanged by capture itself
- **AND** no modules SHALL be compiled, discarded, swapped, or reloaded as a result of capture

#### Scenario: Capture preserves diagnostic state

- **WHEN** a caller captures a snapshot while diagnostics exist
- **THEN** diagnostics SHALL remain available after capture
- **AND** capture SHALL NOT mark diagnostics emitted, clear dirty flags, or append new diagnostics

### Requirement: Snapshot rows are deterministic and diffable

The snapshot capability SHALL produce rows with stable keys and deterministic ordering so two snapshots can be compared mechanically.

#### Scenario: Row keys identify comparable fields

- **WHEN** snapshot rows are produced
- **THEN** each row SHALL include category, identity, field, value, value kind, and source information
- **AND** the combination of category, identity, and field SHALL identify the value being compared by the diff algorithm

#### Scenario: Map and set rows are sorted

- **WHEN** snapshot rows are produced from unordered maps, sets, or symbol maps
- **THEN** those rows SHALL be sorted by stable names, declarations, ids, or pointer identity strings before output
- **AND** repeated captures of unchanged state SHALL NOT produce noisy row-order-only diffs

### Requirement: State diff reports engine impact between snapshots

The runtime SHALL provide a diff capability that compares two engine state snapshots and reports added, removed, and changed rows by stable row key.

#### Scenario: Compile impact is visible in diff

- **WHEN** a caller captures a snapshot, compiles a new script module, captures a second snapshot, and computes a diff
- **THEN** the diff SHALL include changes for the FAS active module state
- **AND** the diff SHALL include changes for the underlying AS engine module/function/type state
- **AND** the diff SHALL include module-local AS internals for the compiled module

#### Scenario: Unchanged state does not dominate default diff output

- **WHEN** two snapshots are compared with default diff options
- **THEN** unchanged rows SHALL be omitted from the main diff table
- **AND** added, removed, and changed rows SHALL remain visible with before and after values where applicable

### Requirement: Dump output includes upgraded snapshot and diff tables

The state dump system SHALL write normalized snapshot and diff CSV tables in addition to existing human-friendly diagnostic CSV tables.

#### Scenario: DumpAll writes snapshot tables

- **WHEN** `FAngelscriptStateDump::DumpAll()` runs successfully
- **THEN** the output directory SHALL contain the existing dump CSV tables
- **AND** it SHALL contain normalized snapshot tables for engine member state, engine collections, AS engine internals, AS module internals, AS type internals, and AS function internals
- **AND** `DumpSummary.csv` SHALL include rows for the new tables

#### Scenario: Diff output is written to CSV

- **WHEN** a caller dumps a computed state diff
- **THEN** the output directory SHALL contain `StateDiff.csv`
- **AND** it SHALL contain a diff summary table grouped by category and change type
- **AND** the CSV rows SHALL include enough identity and before/after value data to inspect compile impact from logs or saved artifacts

### Requirement: Compiler-event tests use shared dump/diff diagnostics

Compiler-event validation SHALL use the shared engine state snapshot and diff utilities when it needs full engine state logging.

#### Scenario: Compiler event test logs full state impact

- **WHEN** the compiler-event test compiles a module for event validation
- **THEN** it SHALL capture before and after engine state snapshots through the shared dump/diff API
- **AND** it SHALL write snapshot and diff artifacts to a unique test output directory
- **AND** it SHALL log the artifact path and diff summary counts for later manual inspection
- **AND** it SHALL NOT maintain a local ad hoc engine diff implementation inside the compiler-event test file
