## ADDED Requirements

### Requirement: TypedASTJIT preserves UASFunction dispatch boundaries

TypedASTJIT SHALL reuse existing `UASFunction` VM/raw/parameter Provider entry dispatch and SHALL NOT bypass virtual, event, RPC, thread-safety, or reflected-parameter behavior to obtain a direct call.

#### Scenario: Reflected scalar call reaches TypedASTJIT parameter entry

- **WHEN** an eligible generated `UASFunction` is invoked through `RuntimeCallEvent` with reflected scalar parameter memory
- **THEN** the existing parameter-entry branch reaches the TypedASTJIT-generated body
- **AND** arguments, return placement, exception state, and test-visible backend marker match the VM contract

#### Scenario: Direct scalar wrapper reaches TypedASTJIT raw entry

- **WHEN** an eligible final scalar function shape uses an existing optimized `UASFunction` wrapper with a raw JIT entry
- **THEN** that wrapper may invoke the TypedASTJIT raw entry through the current dispatch helper
- **AND** it does not require a TypedASTJIT-specific `UASFunction` subclass

#### Scenario: Typed publication preserves the existing script-origin classifier

- **WHEN** normal class generation publishes a reflected AngelScript function whose current binding contains TypedASTJIT entries
- **THEN** the wrapper remains a member of the existing `UASFunction` family and `IsAngelscriptGenerated(const UFunction*)` returns true
- **AND** `IsAngelscriptGenerated(const FProperty*)` returns true for the wrapper's owned argument and return properties while ordinary native function properties remain false
- **AND** discarding or replacing the backing script module does not reclassify the retained stale `UASFunction` UObject as a native function
- **AND** the isolated generation Engine derives root identity from its authoritative descriptor/function graph rather than an AssetRegistry tag, UObject pointer, or duplicate persistent script-origin flag

#### Scenario: Virtual override is not bypassed

- **WHEN** a parent UFUNCTION has TypedASTJIT entries but the receiver resolves to an overriding child implementation
- **THEN** dispatch resolves the current child function before choosing a native or VM entry
- **AND** it never blindly invokes the parent's TypedASTJIT raw pointer

#### Scenario: Event and RPC functions remain routed

- **WHEN** a function is BlueprintEvent, BlueprintOverride, RPC/net, validation/event wrapper, or otherwise requires Unreal routing
- **THEN** UASFunction dispatch preserves its existing `ProcessEvent` or VM route
- **AND** TypedASTJIT eligibility does not attach a raw-direct entry that bypasses that route

#### Scenario: Thread-safe or unsupported wrapper remains on current path

- **WHEN** a thread-safe, WorldContext-sensitive, complex-signature, or otherwise unsupported wrapper shape is encountered
- **THEN** it uses its documented generic/BytecodeJIT/VM dispatch behavior
- **AND** availability of TypedASTJIT for another function does not change that wrapper selection

#### Scenario: Runtime execution requirements override an uninstrumented entry

- **WHEN** the current invocation requires breakpoint/step/local inspection, coverage, timeout, abort, suspend, or recursion behavior absent from the available TypedASTJIT profile or its direct helper closure
- **THEN** normal `UASFunction` dispatch selects the approved VM route before entering the uninstrumented TypedASTJIT body
- **AND** provider availability alone does not override the execution-requirements snapshot
- **AND** a position-only JIT frame is not treated as debugger or safe-point capability

#### Scenario: Public entry adopts nested generated exception metadata

- **WHEN** a VM, parameter or raw UASFunction entry observes a nested TypedASTJIT/BytecodeJIT body or approved bridge finish with script exception state
- **THEN** dispatch preserves the first exception message, originating function and processed source location in the public context before returning `asEXECUTION_EXCEPTION`
- **AND** the existing virtual/event/RPC route remains authoritative while performing that adoption
- **AND** an exception boolean with an empty public context payload is not considered an equivalent entry result
