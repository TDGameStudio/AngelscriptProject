## ADDED Requirements

### Requirement: Editor and PIE attach exact JIT matches after authoritative AS compilation

Editor and PIE SHALL keep source preprocessing, AS compilation, module replacement, ClassGenerator, and class hot reload authoritative. Runtime SHALL publish current VM/Native routes only for an accepted AS generation and SHALL never enable the legacy global FunctionId registration path in Editor.

#### Scenario: Editor starts with a matching project provider

- **WHEN** Editor compiles scripts whose full identities match the loaded project `AngelscriptJIT` provider
- **THEN** ClassGenerator first accepts the authoritative structural generation and matching functions then receive complete Native Bindings before post-compile consumers or the first reflected dispatch observe that generation
- **AND** unmatched functions remain executable through current VM functions

#### Scenario: PIE uses the current Editor engine state

- **WHEN** PIE invokes a function whose Editor route is an exact Native match
- **THEN** PIE may use that Native Binding
- **AND** the route still resolves the current PIE/Editor function and override rather than a generated-process FunctionId

#### Scenario: AS hot reload fails

- **WHEN** a script edit fails compilation or prevents module swap
- **THEN** no route snapshot is published for the failed generation
- **AND** existing modules/routes remain active according to normal hot-reload behavior

### Requirement: Script save invalidates only changed Native entries

Ordinary script save/hot reload SHALL rebuild current function identities without automatically generating C++ or invoking Live Coding. Unchanged exact entries SHALL remain Native and changed/missing entries SHALL use VM immediately after the accepted AS swap.

#### Scenario: One function body changes

- **WHEN** hot reload accepts a new body whose Execution hash has no matching provider entry
- **THEN** that function immediately selects its current VM implementation
- **AND** unrelated exact functions retain Native routes

#### Scenario: Only formatting changes

- **WHEN** hot reload changes Debug hash but preserves executable identity for a runtime-debug-mapped entry
- **THEN** the function remains Native
- **AND** current debug metadata is used for source mapping

#### Scenario: Class or UFUNCTION structure changes

- **WHEN** a class, signature, reflected UFUNCTION contract, or layout changes
- **THEN** normal Hot Reload/ClassGenerator performs the structural update
- **AND** JIT attachment occurs only after the new current functions are accepted and exactly validated

### Requirement: Hot-reloadable Native calls resolve the current callee route

Generated hot-reloadable script-to-script calls MUST identify the callee by stable function key and MUST resolve the current override/function before selecting Native or VM. They MUST NOT directly call a previous content-specific callee symbol.

#### Scenario: Native caller invokes changed callee before refresh

- **WHEN** caller A remains an exact Native match, callee B has new content, and no matching B entry exists
- **THEN** A invokes the current VM implementation of B
- **AND** A cannot call the old Native B symbol

#### Scenario: Refreshed callee becomes exact

- **WHEN** a later provider generation contains exact current content for B
- **THEN** the unchanged Native caller A invokes B through its new Native route

#### Scenario: Virtual callee is overridden

- **WHEN** a routed call targets a virtual function on an object with a current script override
- **THEN** override resolution occurs before Native/VM selection
- **AND** a parent Native entry cannot bypass the child override

### Requirement: Native implementation symbols are content-addressed

Every hot-reloadable Native implementation symbol MUST include the complete stable function key and complete Execution content hash. A changed function MUST produce a different implementation symbol and provider generation.

#### Scenario: Function body changes

- **WHEN** a function retains its stable logical key but receives a different Execution hash
- **THEN** generation emits a different implementation symbol
- **AND** the prior route continues to name only its prior implementation until safe publication

### Requirement: Editor Native refresh is explicit

The Editor SHALL expose `Generate/Refresh AngelScript JIT`. The action SHALL generate the `EditorDevelopment` profile only after a successful current AS compilation. Script save/hot reload MUST NOT automatically start UBT or Live Coding.

#### Scenario: User requests Generate/Refresh

- **WHEN** current scripts compile, the project scaffold is valid, and no generation/patch is active
- **THEN** changed per-AS-module `.jit.cpp` sources, provider metadata, owned-file inventory, and deterministic JSON metadata are generated
- **AND** byte-identical owned files are not rewritten

#### Scenario: Current AS state has errors

- **WHEN** the user requests refresh while the current AS generation is invalid
- **THEN** generation and Live Coding do not start
- **AND** diagnostics identify the AS prerequisite failure

#### Scenario: Provider module is absent from the active target

- **WHEN** the project module has not completed its first full Editor build
- **THEN** the action refuses Live Coding refresh and reports the required build/restart
- **AND** script execution remains VM-correct

#### Scenario: Generated AS module source set changes

- **WHEN** Generate adds or removes a profile `.jit.cpp` because an AS module was added or removed
- **THEN** the owned output and expected ProviderGeneration are updated
- **AND** the action refuses Live Coding refresh and reports the added/removed StableModuleKeys plus the required normal Editor build
- **AND** current execution remains VM-correct until that build loads a compatible provider generation

### Requirement: Live Coding refresh validates the expected patched generation

When UE Live Coding is available, started, and enabled for the session, Generate/Refresh SHALL subscribe to patch completion, call `ILiveCodingModule::Compile()`, and require the expected newer provider generation/artifact-set digest before publishing routes.

#### Scenario: Live Coding patch succeeds

- **WHEN** changed existing per-AS-module `.jit.cpp` sources compile, patch completion fires, and the provider accessor exposes the expected generation
- **THEN** Runtime re-enumerates providers and atomically publishes exact routes at an Engine safe point
- **AND** diagnostics report generation, written files, and Native/VM counts

#### Scenario: Compile cannot start or fails

- **WHEN** Live Coding returns not-started, compile-still-active, failure, cancellation, or another non-success state
- **THEN** no new route snapshot is published
- **AND** the previous exact routes/current VM functions remain active

#### Scenario: Patch completes with a stale provider

- **WHEN** patch completion does not expose the expected generation or manifest digest
- **THEN** the patched provider is rejected for refresh
- **AND** no stale Binding is attached

#### Scenario: Live Coding is unavailable

- **WHEN** platform/configuration/session cannot use Live Coding
- **THEN** valid generated source may remain on disk for a full build
- **AND** current execution remains on VM/previous exact routes

### Requirement: Route refresh respects execution safe points

Provider validation MAY prepare off-thread, but modifying active function Bindings, UASFunction-visible state, resolved references, or route snapshots MUST occur at the Engine compilation/safe-point lifecycle.

#### Scenario: Thread-safe script call is active

- **WHEN** patch completion occurs while an old route can execute
- **THEN** the engine defers rebind or retains the old immutable snapshot until safe
- **AND** no worker thread mutates a cached UFunction entry pointer

### Requirement: Editor route diagnostics remain read-only observers

Structured compilation events SHALL remain value-style read-only observations. JIT attachment SHALL use the Engine compile handoff/safe-point hook and SHALL NOT expose mutable builder/module/provider state through event payloads.

#### Scenario: Compilation listener is registered

- **WHEN** compilation and route attachment occur with a listener
- **THEN** the listener receives summaries of the accepted generation and route result
- **AND** it cannot mutate selection, Binding, builder, or active module state
