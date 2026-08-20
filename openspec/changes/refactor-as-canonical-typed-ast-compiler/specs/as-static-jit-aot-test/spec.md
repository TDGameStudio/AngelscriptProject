## ADDED Requirements

### Requirement: Canonical AST migration reuses semantic and differential oracles
The test suite SHALL migrate existing TypedSemantic HIR and TypedASTJIT fixtures into canonical AST verifier/dump, Bytecode, StaticJIT, cache, and fallback coverage before deleting the corresponding HIR production path. Tests SHALL preserve evaluation order, mutation, conversion, call provenance, cleanup, control target, dependency, exception, recursion, route, eligibility, and Provider entry expectations.

#### Scenario: HIR semantic fixture gains an AST oracle
- **WHEN** a HIR fixture protects a semantic contract required by Bytecode or TypedASTJIT
- **THEN** an equivalent canonical AST fixture proves the same source semantics and verifier failure cases
- **AND** the HIR fixture is removed only after every affected consumer migrates

### Requirement: Compiler differential tests use isolated Engines
Legacy and canonical Parser/Sema/Bytecode pipelines SHALL be compared in separate Engines with identical source, binds, profile, and options. The suite SHALL compare maintained diagnostics, VM result/exception, side-effect order, cleanup, metadata, dependencies, cache summaries, and StaticJIT routes rather than requiring identical instruction bytes.

#### Scenario: Canonical Bytecode is structurally different but equivalent
- **WHEN** the canonical backend emits a different valid instruction sequence
- **THEN** the differential fixture passes only when all observable and persisted-version contracts match

#### Scenario: Canonical compiler changes behavior
- **WHEN** result, exception, diagnostic, side-effect order, cleanup, metadata, dependency, or routing differs
- **THEN** the fixture fails and blocks the relevant migration gate

### Requirement: Public snapshot, Cache V2, Hot Reload, and StaticJIT share one AST oracle
Tests SHALL prove that a same-build retained AST, a public V1 snapshot, a Cache V2 restored snapshot, and a Hot Reload replacement snapshot produce equivalent normalized semantic dumps for the same generation, while leases and stale-generation status remain correct.

#### Scenario: Cache round-trip preserves normalized AST
- **WHEN** a retained source-built module is encoded, restored into a fresh Engine, and acquired through public V1
- **THEN** normalized AST dumps and stable semantic dependencies match
- **AND** Engine-local pointer/ID values are not compared as identity

#### Scenario: Hot Reload preserves old readers
- **WHEN** a reader retains generation A and Hot Reload publishes generation B
- **THEN** both snapshots verify and remain independently traversable
- **AND** only B reports current

### Requirement: Final gates cover native, UE, Standalone, and full-suite behavior
The canonical cutover and legacy/HIR deletion milestones SHALL run focused Native SDK Frontend/Compiler tests, StaticJIT tests, Cache tests, Hot Reload tests, Standalone Debug tests, and the configured All suite through project test entry points. No disabled test or fallback broadening may be used solely to make cutover pass.

#### Scenario: Focused tests pass but full suite fails
- **WHEN** a final migration milestone passes focused compiler/StaticJIT/cache tests but the configured All suite reports a regression
- **THEN** the milestone remains incomplete and the legacy deletion/cutover task is not checked
