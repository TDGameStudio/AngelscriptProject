# static-jit-diagnostics Specification

## Purpose
TBD - created by archiving change improve-static-jit-diagnostics. Update Purpose after archive.
## Requirements
### Requirement: StaticJIT diagnostics are available outside Shipping builds

The runtime SHALL provide a StaticJIT diagnostics surface in non-Shipping builds for inspecting AOT precompiled data, generated function registration, function id mapping, and generated entry execution counts.

#### Scenario: Diagnostics resolve AOT function state

- **WHEN** a non-Shipping build loads and compiles a StaticJIT AOT precompiled cache through the diagnostics surface
- **THEN** diagnostics can resolve the target script function to its StaticJIT function id
- **AND** diagnostics can report whether generated code is registered for that id
- **AND** diagnostics can report how many times the generated entry marker ran

#### Scenario: Shipping excludes diagnostics

- **WHEN** the runtime is compiled for Shipping
- **THEN** the StaticJIT diagnostics surface is not exposed for cache loading, function-id lookup, registry inspection, or execution counters

### Requirement: StaticJIT cache diagnostics do not expand the Engine public API

StaticJIT AOT cache load, cache compile, and function-id lookup operations SHALL NOT be exposed as `FAngelscriptEngine::*ForTesting` public methods.

#### Scenario: AOT tests use diagnostics instead of Engine test APIs

- **WHEN** StaticJIT AOT tests load precompiled fixture cache, compile loaded cache data, and resolve fixture function ids
- **THEN** they use the StaticJIT diagnostics surface
- **AND** they do not call `FAngelscriptEngine::LoadPrecompiledDataForTesting`
- **AND** they do not call `FAngelscriptEngine::CompileLoadedPrecompiledDataForTesting`
- **AND** they do not call `FAngelscriptEngine::GetStaticJITFunctionIdForTesting`

### Requirement: StaticJIT diagnostics include a console command

The runtime SHALL register a non-Shipping console command named `as.StaticJIT.DumpDiagnostics` for human-readable StaticJIT diagnostics.

#### Scenario: Dump process-level StaticJIT diagnostics

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` without arguments in a non-Shipping build
- **THEN** the command logs StaticJIT registration count, execution counter count, compiled-info availability, current engine availability, and precompiled-data availability
- **AND** the command handles missing current engine or precompiled data without crashing

#### Scenario: Dump function-level StaticJIT diagnostics

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` with a function name or declaration in a non-Shipping build
- **THEN** the command attempts to resolve the function in the current engine
- **AND** it logs the resolved StaticJIT function id when available
- **AND** it logs generated registration state, `jitFunction` presence, and execution count for that id
- **AND** it reports a clear diagnostic message if the function cannot be resolved

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

