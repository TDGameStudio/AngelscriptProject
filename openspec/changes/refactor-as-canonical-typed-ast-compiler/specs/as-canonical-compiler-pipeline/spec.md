## ADDED Requirements

### Requirement: Parser constructs canonical AST through Sema actions
The production Parser SHALL invoke Sema actions for declarations, types, statements, and expressions rather than publishing a generic `asCScriptNode` tree as the semantic input. During migration, adapters MAY mirror legacy Parser/Builder results for differential checks, but the final production pipeline MUST NOT require legacy nodes after successful Sema construction.

#### Scenario: Declaration parsing has one final authority
- **WHEN** Parser recognizes a namespace, type, function, property, import, global, parameter, or default argument
- **THEN** Sema validates and constructs the corresponding canonical declaration/type graph
- **AND** later compilation stages do not reparse token nodes to rediscover its semantic identity

#### Scenario: Legacy adapter is non-authoritative
- **WHEN** shadow mode constructs legacy and canonical representations
- **THEN** only the selected pipeline may publish executable output
- **AND** an AST mismatch is reported as differential evidence rather than silently merging the two graphs

### Requirement: Bytecode CodeGen consumes only sealed canonical AST
The canonical Bytecode backend SHALL read sealed AST and own VM temporaries, stack slots, labels, patch lists, exception/cleanup tables, safe points, debug positions, relocations, and final instruction buffers. It MUST NOT perform overload lookup, select implicit conversions, rewrite properties/calls, or invent cleanup absent from AST.

#### Scenario: Bytecode generation does not mutate AST
- **WHEN** the same sealed AST is emitted more than once for the same profile
- **THEN** AST dumps and verification remain unchanged
- **AND** CodeGen-local state is destroyed independently after each emission

#### Scenario: Backend receives an unsealed graph
- **WHEN** Bytecode CodeGen is invoked with an unsealed or invalid AST
- **THEN** it fails before publishing function Bytecode or module state

### Requirement: Shadow convergence compares isolated compiler pipelines
Migration SHALL support development/test-only legacy, canonical, and shadow comparison selections in separate Engines. Shadow comparison SHALL cover compile acceptance, maintained diagnostics, VM results/exceptions, evaluation order, mutation, cleanup, dependencies, debug/coverage/timeout metadata, Cache summaries, and StaticJIT behavior. It SHALL NOT become a permanent Shipping dual compiler.

#### Scenario: Behavioral parity permits different instructions
- **WHEN** legacy and canonical pipelines emit different Bytecode instruction sequences for the same accepted source
- **THEN** parity succeeds only if observable execution, exceptions, cleanup, metadata contracts, stable dependencies, and persistence-version rules match
- **AND** byte inequality remains available as diagnostics but is not itself a failure

#### Scenario: Semantic mismatch blocks cutover
- **WHEN** isolated legacy/canonical execution differs in result, diagnostic contract, side-effect order, cleanup, exception, route, or dependency behavior
- **THEN** canonical cutover for that milestone is blocked and legacy remains authoritative

### Requirement: Canonical frontend covers every currently accepted construct before final cutover
Before the canonical pipeline becomes the only production compiler, every active AngelScript SDK, plugin compiler, Script corpus, Standalone, and UE integration fixture that currently compiles SHALL have a valid canonical representation and equivalent Bytecode behavior. Executable fallback to legacy Parser/Sema/HIR is forbidden after final cutover.

#### Scenario: Accepted construct lacks canonical representation
- **WHEN** an active fixture compiles in the legacy frontend but produces an unsupported executable canonical node
- **THEN** the final cutover gate fails
- **AND** the legacy path cannot be removed for that milestone

#### Scenario: StaticJIT rejects a valid canonical form
- **WHEN** canonical Sema/AST/Bytecode support a construct outside current TypedASTJIT native eligibility
- **THEN** the function remains valid and executes through BytecodeJIT/VM fallback
- **AND** this does not count as incomplete canonical frontend coverage

### Requirement: Final cutover removes duplicate semantic production paths
After all parity gates pass, the canonical pipeline SHALL become the sole production source compiler. The maintained fork SHALL remove the function-owned HIR builder/accessors/capture identity, `asCExprContext` Bytecode/HIR mixing, and production semantic dependence on `asCScriptNode`. No production setting SHALL select the removed legacy or dual pipeline.

#### Scenario: Final source scan has no legacy body authority
- **WHEN** the completed change is scanned and the full suite is executed
- **THEN** Bytecode and TypedASTJIT originate from canonical AST
- **AND** no production compiler path builds or consumes function-owned TypedSemantic HIR or uses `asCScriptNode` as a semantic body representation

#### Scenario: Old cached AST/HIR format is encountered
- **WHEN** a Runtime encounters an unsupported legacy HIR/AST sidecar or compiler payload version after cutover
- **THEN** it reports a normal incompatibility/miss and recompiles from authoritative source when allowed
- **AND** it never reinterprets old bytes as the new schema

### Requirement: Compiler components preserve standalone and host boundaries
SourceManager, Parser, Sema, ASTContext, verifier, DTO codec, and Bytecode CodeGen SHALL remain standard-C++ maintained-fork components without Unreal container/UObject dependencies. UE Runtime and Standalone hosts SHALL use the same frontend semantics through host-specific source/bind/runtime bridges.

#### Scenario: Standalone compiles canonical AST
- **WHEN** the Standalone host builds and executes a supported native-runtime script or analyzes a ue-validation script
- **THEN** it uses the same canonical Parser/Sema/AST/Bytecode implementation as the UE-maintained fork
- **AND** it does not require Unreal Engine or Clang/LLVM libraries
