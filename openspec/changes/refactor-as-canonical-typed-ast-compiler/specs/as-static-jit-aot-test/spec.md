## ADDED Requirements

### Requirement: Canonical AST migration reuses semantic and differential oracles
The test suite SHALL preserve migrated TypedSemantic-HIR-era and TypedASTJIT fixtures as canonical AST/protocol verifier, Bytecode, StaticJIT, cache, and fallback coverage while keeping the corresponding HIR production path physically absent. Tests SHALL preserve evaluation order, mutation, conversion, call provenance, lifetime activation/commit, reverse live-only cleanup, partial construction, control target, dependency, exception, recursion, route, eligibility, and Provider entry expectations.

#### Scenario: HIR-era semantic contract remains covered without HIR
- **WHEN** a retired HIR fixture protected a semantic contract required by Bytecode or TypedASTJIT
- **THEN** an equivalent canonical AST/protocol fixture proves the same source semantics and verifier failure cases
- **AND** no retired HIR type, file, capture setting, accessor, dump, or transport is restored to run the fixture

#### Scenario: Lifetime protocol parity is forged and source-tested
- **WHEN** a lifetime slice adds or changes action, activation, construction, region, phase, transfer, exception, or suspend facts
- **THEN** a source-built AST-first RED/GREEN proves the exact sealed facts and a forged-protocol negative proves final publication rejection
- **AND** Bytecode and TypedASTJIT acceptance/fallback are compared against the same verified protocol revision

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

### Requirement: Final gates cover native, UE, and full-suite behavior
The Canonical lifetime-protocol closure, final cutover, permanent HIR-absence gate, and explicit LEGACY-isolation milestones SHALL run focused Native SDK Frontend/Compiler tests, StaticJIT tests, Cache boundary tests, Hot Reload tests, and the configured All suite through project test entry points. No disabled test or fallback broadening may be used solely to make cutover pass. Standalone Debug/Release adaptation and verification are explicitly deferred to a separate future OpenSpec and are not evidence required by these milestones. These milestones do not authorize deletion of the native `asCScriptNode`/Builder/Compiler implementation.

#### Scenario: Focused tests pass but full suite fails
- **WHEN** a final migration milestone passes focused compiler/StaticJIT/cache tests but the configured All suite reports a regression
- **THEN** the milestone remains incomplete and the legacy deletion/cutover task is not checked
