## ADDED Requirements

### Requirement: Diagnostics identify canonical AST generation and eligibility
StaticJIT diagnostics SHALL report requested/actual backend, target profile, module/function stable identity, AST retention policy, snapshot generation key, current/stale state, verification result, eligibility/call disposition, fallback reason, and Provider output identity without exposing raw AST or Engine pointer values.

#### Scenario: Typed generation succeeds
- **WHEN** a verified retained canonical AST function emits through TypedASTJIT
- **THEN** diagnostics identify its AST generation, eligible typed route, semantic dependencies, and produced Provider entries

#### Scenario: Typed generation falls back
- **WHEN** canonical AST is valid but the native emitter rejects a current unsupported form or unproven route/linkage contract
- **THEN** diagnostics distinguish AST validity from TypedASTJIT ineligibility
- **AND** report the selected BytecodeJIT/VM fallback

### Requirement: AST inspection is distinct from artifact generation
AST snapshot dump/inspection diagnostics SHALL identify source-built versus Cache-restored origin, API/schema version, verification, retention, generation, and stale/current state. They MUST NOT report that a dump request generated a Provider, selected a fallback backend, or supplied a compiler/cache input.

#### Scenario: Developer dumps a retained snapshot
- **WHEN** a developer performs read-only AST inspection
- **THEN** diagnostics report snapshot provenance and verification only
- **AND** StaticJIT generation counters and output ownership remain unchanged

### Requirement: Legacy HIR diagnostic names retire after migration
After HIR consumers are removed, production diagnostics and settings SHALL use canonical AST/snapshot terminology. Compatibility aliases MAY exist only for one documented transition and MUST NOT imply that `.hir.txt/.hir.json` or old HIR sidecars are accepted inputs.

#### Scenario: Old HIR cache or dump is encountered
- **WHEN** a post-cutover tool sees an old HIR sidecar/schema/dump
- **THEN** diagnostics report unsupported legacy data and the safe miss/migration path
- **AND** no canonical AST is fabricated from it
