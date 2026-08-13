## ADDED Requirements

### Requirement: JIT diagnostics report coordinator tier decisions

Non-Shipping JIT diagnostics SHALL report configured execution mode, requested/actual Static BackendId, typed-HIR capture profile, Static fallback chain, selected Runtime BackendId, compile policy, backend availability, per-function requested/actual tier, compile state, typed fallback reason, compile latency, generated code size, stale/cancel counts, and live/retired code-lease counts. Existing StaticJIT AOT diagnostics and `as.StaticJIT.DumpDiagnostics` behavior SHALL remain available.

#### Scenario: Static module mixes TypedASTJIT and BytecodeJIT

- **WHEN** one Provider module contains TypedASTJIT entries and per-function BytecodeJIT fallbacks
- **THEN** diagnostics report `"typed-ast"` as the requested backend and the actual backend for each emitted function
- **AND** fallback functions include the stable TypedASTJIT reason without changing their Provider identity

#### Scenario: Generation capture profile is invalid

- **WHEN** a `"typed-ast"` generation request is paired with a capture-off Engine
- **THEN** generation diagnostics report `CaptureProfileMismatch` as a task-level configuration error
- **AND** no function is described as a TypedASTJIT hit

#### Scenario: Function uses Runtime Native

- **WHEN** a function has a current Binding from the selected Runtime backend
- **THEN** diagnostics identify the backend, compile policy, current source revision, Runtime actual tier, compile latency, code size, and execution marker count

#### Scenario: Function falls back to VM

- **WHEN** Runtime compilation is unavailable, unsupported, gated, failed, cancelled, or stale
- **THEN** diagnostics distinguish those outcomes
- **AND** they do not describe the function as a Native hit merely because a request was created

#### Scenario: Static AOT remains selected

- **WHEN** `Auto` finds an exact Static AOT Binding before a compiled Runtime Binding
- **THEN** diagnostics report Static AOT as the selected tier
- **AND** the existing provider identity/generation and AOT marker details remain inspectable

#### Scenario: Shipping excludes coordinator diagnostics

- **WHEN** the runtime is compiled for Shipping
- **THEN** Runtime compile queues, code-lease inspection, and per-function coordinator diagnostic commands are not exposed
- **AND** the existing Shipping exclusions for StaticJIT diagnostics remain intact
