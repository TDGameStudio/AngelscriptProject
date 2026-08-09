## ADDED Requirements

### Requirement: Editor and PIE attach exact StaticJIT matches after AS compilation

Editor and PIE SHALL keep source preprocessing, AS compilation, module replacement, and ClassGenerator as the authoritative lifecycle. After a successful AS compile and before class generation handoff, Runtime SHALL attach exact provider matches and VM routes for misses.

#### Scenario: Editor starts with a matching provider

- **WHEN** Editor compiles scripts whose full identities match a loaded project provider
- **THEN** matching functions receive Native routes before generated UFunctions are finalized
- **AND** unmatched functions remain executable through VM

#### Scenario: AS hot reload fails

- **WHEN** a script edit fails AS compilation or prevents module swap
- **THEN** no route snapshot is published for the failed AS generation
- **AND** existing script modules/routes remain active according to normal hot-reload behavior

### Requirement: Hot-reloadable script calls resolve the current callee route

Generated hot-reloadable script-to-script calls MUST select the current resolved callee and its current Native/VM route rather than directly calling a previous content-specific implementation symbol.

#### Scenario: Native caller invokes changed callee before refresh

- **WHEN** caller A remains an exact Native match, callee B is recompiled with new content, and no matching Native B entry exists yet
- **THEN** A invokes the current VM implementation of B
- **AND** A does not call the old Native B symbol

#### Scenario: Callee receives a matching refreshed entry

- **WHEN** a later validated provider generation contains exact Native content for B
- **THEN** the same unchanged Native caller A invokes the current Native B route

#### Scenario: Virtual callee is overridden

- **WHEN** a routed call targets a virtual function on an object with a current script override
- **THEN** override resolution occurs before Native/VM route selection
- **AND** the parent implementation is not called merely because it has a Native entry

### Requirement: Native implementation symbols are content-addressed

Every generated Native implementation symbol in a hot-reloadable provider MUST include the complete stable function key and complete selected function-content hash. A changed function MUST produce a different implementation symbol.

#### Scenario: Function body changes

- **WHEN** a function keeps its stable logical key but receives a new content hash
- **THEN** generation emits a new content-specific implementation symbol
- **AND** the prior validated route continues to name only the old symbol until a new route snapshot is published

### Requirement: Editor Native refresh is explicit

The Editor SHALL provide an explicit Generate/Refresh StaticJIT action that generates changed provider artifacts and invokes Live Coding only after the user requests it. Ordinary script save/hot reload MUST NOT automatically start C++ compilation.

#### Scenario: Script is saved

- **WHEN** an AS body changes and normal hot reload succeeds
- **THEN** the changed function immediately executes through VM
- **AND** no UBT or Live Coding request starts automatically

#### Scenario: User requests Generate/Refresh

- **WHEN** current scripts compile successfully and the project module scaffold is valid
- **THEN** changed slices/aggregators/manifest are generated
- **AND** unchanged byte-identical slices are not rewritten

### Requirement: Live Coding refresh validates patch completion

When UE Live Coding is available and enabled, Generate/Refresh SHALL call `ILiveCodingModule::Compile()`, wait for the patch-complete delegate, require a newer valid provider generation, and publish routes only after full validation.

#### Scenario: Live Coding patch succeeds

- **WHEN** generated artifacts compile and patch completion exposes the expected newer provider generation
- **THEN** Runtime refreshes providers and atomically publishes exact matches
- **AND** diagnostics report the generation and Native/VM counts

#### Scenario: Live Coding compile or patch fails

- **WHEN** generation, Live Coding compilation, patch completion, or provider validation fails
- **THEN** no new route snapshot is published
- **AND** affected functions continue using VM or the previous exact route without terminating the Editor session

#### Scenario: Live Coding is unavailable

- **WHEN** the platform/configuration/session cannot use Live Coding
- **THEN** Generate may write valid source artifacts and reports that a full build/restart is required
- **AND** correctness remains on VM/previous exact routes

### Requirement: Route refresh respects execution safe points

Provider enumeration and manifest validation MAY prepare off-thread, but attaching entries to active AS functions/UFunctions and publishing route snapshots MUST run under the engine compilation/safe-point lifecycle.

#### Scenario: Thread-safe script call is active

- **WHEN** patch completion occurs while a script context can still execute an old route
- **THEN** the engine defers active-function rebind or retains the old snapshot until the call is safe
- **AND** it does not mutate a cached UFunction pointer from the worker thread

### Requirement: Editor route diagnostics remain read-only observers

Structured compilation events SHALL remain read-only. StaticJIT route attachment SHALL use the engine's compile handoff/safe-point hook rather than exposing mutable builder or module internals through compilation events.

#### Scenario: Compilation listener is registered

- **WHEN** Editor compilation and StaticJIT route attachment occur with a structured event listener
- **THEN** the listener receives value-style summaries
- **AND** it cannot mutate provider selection, route state, builder state, or active modules through the event payload
