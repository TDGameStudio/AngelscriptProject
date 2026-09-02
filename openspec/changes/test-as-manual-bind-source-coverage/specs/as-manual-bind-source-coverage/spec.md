## ADDED Requirements

### Requirement: Manual Bind surfaces remain traceable to exact source cases

Every AS-facing manual Bind surface SHALL retain its stable BindId/SurfaceId and SHALL map to at least one exact TestSource case, callable declaration, and typed vector.

#### Scenario: Surface maps to reviewed source

- **WHEN** a Bind surface is migrated
- **THEN** its contract records the current Bind source declaration and representative C++ evidence
- **AND** names the exact TestSource path and callable declaration that exercise it
- **AND** records a concrete no-current-test disposition when no representative C++ oracle exists

#### Scenario: Native-only shard is not fabricated

- **WHEN** a Bind shard contains only adaptation, thunk, debugger/default conversion, CppForm, or registration infrastructure
- **THEN** it remains native-only evidence owned by its logical Bind unit
- **AND** no artificial AS callable is created solely to satisfy a file or surface count

### Requirement: Bind entries expose raw API behavior

Bindings source SHALL expose actual return values, writebacks, aliases, identities, container states, or diagnostics instead of only returning a compound success predicate.

#### Scenario: Scalar or bool query is exercised

- **WHEN** a query returns a scalar or bool
- **THEN** caller-controlled inputs appear in the entry declaration
- **AND** the raw API result is returned
- **AND** vectors cover applicable default, true/false, present/missing, zero/non-zero, and boundary values

#### Scenario: Container mutation is exercised

- **WHEN** a Bind mutates a container
- **THEN** the container is an explicit inout parameter or an explicit output
- **AND** vectors record complete before/after elements, size, ordering, duplicates, alias/copy independence, and failure behavior as applicable

#### Scenario: Object query or construction is exercised

- **WHEN** a Bind accepts or returns UObject-like values
- **THEN** contracts preserve raw handles for null, class, outer, name, flags, CDO, world, and identity checks
- **AND** object construction separates each boundary form instead of creating several objects and collapsing them into one Boolean

### Requirement: TArray provides the complete migration pilot

All TArray sources SHALL migrate before the remaining Bindings and SHALL demonstrate the v2 naming, signature, vectors, comments, and negative-diagnostic rules.

#### Scenario: TArray positive matrix is complete

- **WHEN** the TArray pilot is strict
- **THEN** it covers empty/populated, duplicates, first/missing lookup, copy independence, move-source state, append/insert/add-unique/remove, ordered and swap mutation, sort direction, mutable and const iterator behavior, capacity relations, and shuffle invariants
- **AND** the 40 prior positive compound bool wrappers are replaced by reviewed semantic entries

#### Scenario: TArray negative matrix is complete

- **WHEN** invalid index or iterator exhaustion is covered
- **THEN** the negative trigger has a behavior-specific name and caller-controlled invalid input
- **AND** the contract records the expected exception or diagnostic
- **AND** unrelated positive declarations remain isolated

### Requirement: Fixture and execution safety are explicit

Every Bind case requiring World, Actor, Component, asset, subsystem, platform, file, console, URL, clipboard, process, or global state SHALL declare deterministic setup, execution policy, and cleanup.

#### Scenario: Required fixture is absent

- **WHEN** a required fixture cannot be supplied
- **THEN** the case reports setup failure or an explicit unsupported state
- **AND** it does not accept null fixture state as successful API behavior

#### Scenario: High-impact behavior is represented safely

- **WHEN** a surface can exit, travel, launch an external URL, mutate clipboard/file/console/global state, or otherwise invalidate the host
- **THEN** its contract uses FixtureIsolated, SubprocessOnly, DiagnosticOnly, or CompileOnlyPendingHarness
- **AND** it is excluded from default execution
- **AND** compile-only status does not count as runtime coverage

### Requirement: Bind migration is mechanically closed

The Bind surface inventory, authored contracts, source declarations, generated tasks, and strict audit SHALL form a deterministic closed set.

#### Scenario: Bind domain validates

- **WHEN** a logical Bind domain is complete
- **THEN** every planned source and callable has one reviewed contract and one generated task entry
- **AND** declaration, SurfaceId, path, comment, vector, fixture, cleanup, and execution-policy checks pass
- **AND** no legacy source alias remains

#### Scenario: Bind plan is fully predesigned

- **WHEN** Bind source implementation has not started
- **THEN** every current callable and source-only assertion is reconciled against the canonical owner-qualified inventory
- **AND** each proposed callable has its own review task containing exact semantic name, AngelScript declaration, external inputs, raw results/writebacks, concrete vectors, comment, fixture/cleanup, surface evidence, and blocker state
- **AND** unresolved surface ownership or diagnostic evidence remains an explicit design blocker rather than an implementation-time guess
