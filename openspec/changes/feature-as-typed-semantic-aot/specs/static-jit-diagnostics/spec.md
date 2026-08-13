## ADDED Requirements

### Requirement: StaticJIT diagnostics expose TypedASTJIT selection and fallback

Non-Shipping StaticJIT diagnostics SHALL distinguish the requested generation backend, typed HIR state, UFUNCTION-root eligibility, actual per-function execution backend, typed fallback reason, external-linkage disposition of resolved native calls, and required/available execution-observability/control capabilities.

#### Scenario: Eligible TypedASTJIT function is diagnosed

- **WHEN** diagnostics inspect a UFUNCTION emitted by TypedASTJIT
- **THEN** they report requested BackendId `typed-ast`, valid HIR availability, eligible root state, actual backend `typed-ast`, produced entry kinds, and execution count

#### Scenario: Ineligible function reports source-located fallback

- **WHEN** diagnostics inspect a function that TypedASTJIT rejected
- **THEN** they report the stable fallback category, deterministic detail, and source location when applicable
- **AND** they report whether actual execution uses BytecodeJIT or VM

#### Scenario: Bytecode-only function reports missing HIR

- **WHEN** diagnostics inspect a function without source-compiled typed HIR under a `typed-ast` request
- **THEN** they report `MissingTypedIR`
- **AND** they do not claim that BytecodeJIT fallback is TypedASTJIT output

#### Scenario: Dump command preserves deterministic fields

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` for the same function state repeatedly
- **THEN** backend, HIR, eligibility, fallback, entry-kind, and execution fields appear in stable order
- **AND** process pointer values are not used as persistent function identity

#### Scenario: Exported direct call reports its proof class

- **WHEN** a TypedASTJIT function emits a native direct call
- **THEN** diagnostics identify `DirectExported`, `DirectInline`, or `RuntimeThunk` together with stable header and owning-module fields
- **AND** they do not expose process addresses as linkage proof

#### Scenario: Unexported native form is bridged

- **WHEN** a BytecodeJIT native form has generated C++ spelling but lacks a valid external-call descriptor
- **THEN** diagnostics report `Bridge` with a stable missing-declaration, internal-linkage, missing-export, private-dependency, unknown-module, or ABI-unproven detail
- **AND** they do not claim a native direct call

#### Scenario: Global or imported route fallback is diagnosed

- **WHEN** TypedASTJIT eligibility encounters mutable global storage, a global initializer body, an unproven imported binding slot, or a shared/external body without authoritative ownership
- **THEN** diagnostics report `UnsupportedGlobalStorage`, `UnsupportedGlobalInitializer`, `UnsupportedImportedRoute`, or the specific `UnsupportedCall` detail with processed source provenance
- **AND** they do not expose engine ids, pointers, `boundFunctionId`, or process addresses as stable identity

#### Scenario: Dependency mismatch identifies semantic use

- **WHEN** an HIR semantic use has no compatible compiler artifact dependency or stable host mapping
- **THEN** diagnostics report `SemanticDependencyMismatch`, the use kind, and stable target/provenance fields
- **AND** no partial TypedASTJIT entry is reported

#### Scenario: Invalid call evaluation sequence is diagnosed

- **WHEN** HIR call verification detects a duplicate, missing, dangling, or inconsistent receiver/argument evaluation entry
- **THEN** diagnostics report `InvalidCallEvaluationSequence` with the call source provenance
- **AND** emission and registration are absent

#### Scenario: Invalid control target is diagnosed

- **WHEN** HIR verification finds a dangling, non-ancestor, wrong-kind, or non-nearest break/continue target
- **THEN** diagnostics report `InvalidControlTarget`, transfer kind, target statement ID/kind when available, and processed source provenance
- **AND** emission and registration are absent

#### Scenario: Position-only capability is not overstated

- **WHEN** a generated function has JIT frame/file/line metadata but no approved line callback or inspectable-local implementation
- **THEN** diagnostics report `FramePosition` or equivalent position-only capability
- **AND** debugger-step, debugger-locals, coverage, timeout, abort, and suspend capabilities remain false

#### Scenario: Execution requirement fallback is diagnosed

- **WHEN** a breakpoint, step, local-inspection, coverage, timeout, abort, suspend, or recursion requirement cannot be satisfied by the complete direct TypedASTJIT call closure
- **THEN** diagnostics report `UnsupportedExecutionObservability` or `UnsupportedExecutionControl`, the required and available capability sets, and a stable detail such as `CoverageHookUnavailable`, `LoopTimeoutSafepointUnavailable`, `RecursionGuardUnavailable`, or `DirectCalleeProfileMismatch`
- **AND** actual backend/route reports VM rather than an uninstrumented TypedASTJIT execution

#### Scenario: Instrumentation profile is visible and deterministic

- **WHEN** diagnostics inspect position-only and safe-point-instrumented artifacts for the same HIR
- **THEN** they report distinct stable instrumentation profile/content identity fields
- **AND** they do not use function pointers, frame addresses, or process-local route addresses as identity

#### Scenario: Exception payload capability is not overstated

- **WHEN** a generated entry can set only the current JIT exception boolean but cannot preserve message/function/source metadata through its selected bridge and public context route
- **THEN** diagnostics report exception-control capability separately from exception-payload capability
- **AND** mixed-route parity is false with a stable detail such as `ExceptionPayloadUnavailable` or `BridgeExceptionAdoptionUnavailable`

#### Scenario: Cleanup plan state is visible

- **WHEN** eligibility analyzes a function's normal and exceptional exits
- **THEN** diagnostics report whether cleanup is explicitly empty, verified non-empty, unsupported lifetime, or unsupported exception-region metadata
- **AND** the report identifies the first responsible scope or processed source span without dumping process-local pointers

#### Scenario: Primary exception origin is deterministic

- **WHEN** a test diagnostic snapshot observes a failed TypedASTJIT/BytecodeJIT/VM mixed invocation
- **THEN** it reports the primary backend/route origin, adoption state and payload availability in stable fields
- **AND** cleanup or propagation does not overwrite those fields with a later wrapper origin

#### Scenario: Shipping excludes TypedASTJIT diagnostics

- **WHEN** the runtime is compiled for Shipping
- **THEN** HIR inspection, eligibility details, differential symbols, and TypedASTJIT fallback diagnostics are not exposed through the non-Shipping diagnostics surface
