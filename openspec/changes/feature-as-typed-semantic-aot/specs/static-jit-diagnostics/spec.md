## ADDED Requirements

### Requirement: StaticJIT diagnostics expose Semantic AOT selection and fallback

Non-Shipping StaticJIT diagnostics SHALL distinguish the requested generation backend, typed HIR state, UFUNCTION-root eligibility, actual per-function execution backend, typed fallback reason, and the external-linkage disposition of resolved native calls.

#### Scenario: Eligible Semantic function is diagnosed

- **WHEN** diagnostics inspect a UFUNCTION emitted by Semantic AOT
- **THEN** they report requested backend `Semantic`, valid HIR availability, eligible root state, actual backend `Semantic`, produced entry kinds, and execution count

#### Scenario: Ineligible function reports source-located fallback

- **WHEN** diagnostics inspect a function that Semantic AOT rejected
- **THEN** they report the stable fallback category, deterministic detail, and source location when applicable
- **AND** they report whether actual execution uses legacy StaticJIT or VM

#### Scenario: Bytecode-only function reports missing HIR

- **WHEN** diagnostics inspect a function loaded without source-semantic HIR under a Semantic request
- **THEN** they report `MissingTypedIR`
- **AND** they do not claim that bytecode reconstruction is Semantic AOT

#### Scenario: Dump command preserves deterministic fields

- **WHEN** a developer runs `as.StaticJIT.DumpDiagnostics` for the same function state repeatedly
- **THEN** backend, HIR, eligibility, fallback, entry-kind, and execution fields appear in stable order
- **AND** process pointer values are not used as persistent function identity

#### Scenario: Exported direct call reports its proof class

- **WHEN** a Semantic function emits a native direct call
- **THEN** diagnostics identify `DirectExported`, `DirectInline`, or `RuntimeThunk` together with stable header and owning-module fields
- **AND** they do not expose process addresses as linkage proof

#### Scenario: Unexported native form is bridged

- **WHEN** a legacy native form has generated C++ spelling but lacks a valid external-call descriptor
- **THEN** diagnostics report `Bridge` with a stable missing-declaration, internal-linkage, missing-export, private-dependency, unknown-module, or ABI-unproven detail
- **AND** they do not claim a native direct call

#### Scenario: Shipping excludes Semantic diagnostics

- **WHEN** the runtime is compiled for Shipping
- **THEN** HIR inspection, eligibility details, Dual symbols, and Semantic fallback diagnostics are not exposed through the non-Shipping diagnostics surface
