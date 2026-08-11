## ADDED Requirements

### Requirement: Delegate dispatch performance baselines
The plugin SHALL provide a repeatable automation benchmark and correctness matrix for script-declared single-cast delegates and multicast events. The matrix SHALL report setup separately from dispatch and SHALL cover interpreter and StaticJIT execution where StaticJIT is available.

#### Scenario: Single-cast primitive dispatch baseline
- **WHEN** the benchmark executes a bound script-declared single-cast delegate with primitive parameters in interpreter and StaticJIT configurations
- **THEN** it SHALL record comparable dispatch measurements and assert the expected target invocation count in both configurations

#### Scenario: Multicast listener scaling baseline
- **WHEN** the benchmark executes a script-declared multicast event with 1, 4, 16, and 64 compatible listeners
- **THEN** it SHALL record dispatch measurements for each listener count and assert that every live listener receives the expected invocation

#### Scenario: Parameter-shape baseline
- **WHEN** the benchmark executes delegate signatures containing primitive, value-struct, and reference/container parameter forms supported by the binding system
- **THEN** it SHALL verify parameter values and reference copy-back semantics while recording each parameter-shape result separately

### Requirement: Dynamic delegate semantic preservation
Any dispatch optimization for script-declared `delegate` and `event` types SHALL preserve Unreal dynamic delegate semantics and SHALL not replace the public reflected delegate path with a native `TDelegate` implementation.

#### Scenario: Blueprint-visible event remains reflected
- **WHEN** a script-declared event is used in a reflected delegate property and bound from a Blueprint-compatible target
- **THEN** it SHALL retain its generated `UDelegateFunction` signature and dispatch through the UE dynamic delegate path after optimization

#### Scenario: Binding is invalidated safely after reload
- **WHEN** a script delegate signature or bound target function changes through a full reload or Blueprint reinstance
- **THEN** subsequent execution SHALL revalidate or invalidate cached compatibility before dispatch and SHALL not execute a stale incompatible target

#### Scenario: Destroyed listener remains safe
- **WHEN** a multicast event contains a listener whose UObject is destroyed before broadcast
- **THEN** dispatch SHALL retain Unreal dynamic delegate lifetime behavior and SHALL not dereference the destroyed object

### Requirement: StaticJIT delegate fast-path coverage
The StaticJIT test suite SHALL verify that supported delegate execution and event broadcasting use the registered delegate, multicast, and argument-marshalling native forms when emitted as AOT code.

#### Scenario: Generated single-cast wrapper is emitted with a native-form call
- **WHEN** StaticJIT emits code for a script method that executes a script-declared single-cast delegate
- **THEN** the generated output or native-form diagnostics SHALL demonstrate delegate execution through the StaticJIT delegate native form and the runtime result SHALL match interpreter execution

#### Scenario: Generated multicast wrapper is emitted with a native-form call
- **WHEN** StaticJIT emits code for a script method that broadcasts a script-declared event
- **THEN** the generated output or native-form diagnostics SHALL demonstrate multicast execution through the StaticJIT multicast native form and every compatible listener SHALL be invoked

### Requirement: Reflected and pure-script callback guidance
The project documentation SHALL distinguish reflected `delegate` / `event` usage from pure-script callback usage, and SHALL state that the existing reflected delegate API is designed to approach UE dynamic delegate cost rather than native `TDelegate` cost under StaticJIT.

#### Scenario: High-frequency callback selection guidance
- **WHEN** a developer consults delegate performance guidance for a high-frequency callback that does not require Blueprint or UPROPERTY support
- **THEN** the guidance SHALL identify `funcdef` / function-handle investigation as the future non-reflected alternative and SHALL not recommend per-tick dynamic event broadcast as the default solution
