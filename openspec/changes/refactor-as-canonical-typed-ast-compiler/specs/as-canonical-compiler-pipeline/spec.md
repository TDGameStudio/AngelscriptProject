## ADDED Requirements

### Requirement: Parser constructs canonical AST through Sema actions
When CANONICAL is selected, Parser SHALL invoke typed Sema actions for declarations, types, statements, and expressions rather than publishing the generic `asCScriptNode` tree as semantic input. Parser MAY continue constructing the native syntax tree for syntax/recovery support, parser tests, and the separately selected LEGACY pipeline. During migration, adapters MAY mirror legacy Parser/Builder results for differential checks, but completed CANONICAL Sema and its backends MUST NOT require semantic replay of legacy nodes. This change does not physically remove the native syntax tree.

#### Scenario: Declaration parsing has one final authority
- **WHEN** Parser recognizes a namespace, type, function, property, import, global, parameter, or default argument
- **THEN** Sema validates and constructs the corresponding canonical declaration/type graph
- **AND** later compilation stages do not reparse token nodes to rediscover its semantic identity

#### Scenario: Legacy adapter is non-authoritative
- **WHEN** shadow mode constructs legacy and canonical representations
- **THEN** only the selected pipeline may publish executable output
- **AND** an AST mismatch is reported as differential evidence rather than silently merging the two graphs

### Requirement: Bytecode CodeGen consumes only Frozen/Publishable canonical facts
The canonical Bytecode backend SHALL read a Frozen/Publishable AST plus its verifier-authenticated Canonical lifetime protocol/shared derived view and SHALL own VM temporaries, stack slots, labels, patch lists, backend-local cleanup/EH stacks, exception/cleanup tables, safe points, debug positions, relocations, and final instruction buffers. Before module mutation it SHALL produce a detached artifact whose durable type/property/function dependencies use complete stable symbolic identity plus expected target/profile ABI-layout compatibility. Candidate installation SHALL resolve the complete relocation set into an immutable generation-local Runtime binding view before atomically publishing executable state and its AST snapshot. The backend MUST NOT perform overload lookup, select implicit conversions, rewrite properties/calls, select or replace a semantic cleanup action, repeat lifetime-family/destructor classification, reinterpret an invalid/missing protocol as no-cleanup, or use an Engine-local numeric type ID as a durable or cross-generation symbol. It MAY mechanically lower verified action routing into backend labels, active flags, shared cleanup blocks, and physical exception tables.

#### Scenario: Bytecode generation does not mutate AST
- **WHEN** the same sealed AST is emitted more than once for the same profile
- **THEN** AST dumps and verification remain unchanged
- **AND** CodeGen-local state is destroyed independently after each emission

#### Scenario: Backend receives an unsealed graph
- **WHEN** Bytecode CodeGen is invoked with an unsealed or invalid AST
- **THEN** it fails before publishing function Bytecode or module state

#### Scenario: Backend receives an invalid lifetime protocol
- **WHEN** the AST is structurally sealed but its lifetime protocol revision, activation, construction prefix, edge coverage, action identity, or order fails final verification
- **THEN** Bytecode generation fails before publishing function Bytecode or module state
- **AND** it does not infer cleanup from type names, magic literals, dump text, or the previous active generation

#### Scenario: Backend lowers verified cleanup through local state
- **WHEN** the shared lifetime/control view proves exact normal, transfer, or supported failure cleanup actions
- **THEN** Bytecode CodeGen may allocate local slots, active bits, labels, patches, cleanup blocks, and exception-table entries for that emission
- **AND** those physical values are absent from Canonical AST, Public AST, Cache DTO, Provider identity, and cross-generation symbols

#### Scenario: Candidate type relocation cannot resolve exactly
- **WHEN** a detached artifact contains a missing, ambiguous, stale, wrong-owner, wrong-profile, or ABI-layout-incompatible type/property/function relocation
- **THEN** installation fails before module, function, type, global, snapshot, generation-key, or Runtime-binding publication
- **AND** the complete last-good generation remains executable and current

#### Scenario: Active bytecode uses installed Runtime operands
- **WHEN** candidate installation resolves the complete relocation set successfully
- **THEN** active bytecode may use generation-local type pointers, property offsets, compact binding slots, or current numeric type IDs required by the VM/public ABI
- **AND** VM execution does not perform stable-key string or hash lookup for each instruction
- **AND** those active operands remain valid until the owning generation lease is released

#### Scenario: Durable artifact is inspected for Engine-local identity
- **WHEN** a detached CodeGen artifact, public AST view, diagnostic dump, optional AST DTO, or StaticJIT Provider identity is serialized or compared
- **THEN** it contains no publishing-Engine `asCTypeInfo*`, numeric type ID, property pointer, or snapshot-local type reference as durable identity
- **AND** hashes are accompanied by complete-key verification rather than accepted alone

#### Scenario: Lexical interfaces publish through the detached generation transaction
- **WHEN** a verified Canonical module declares interfaces, inherited interfaces, implementing classes, and authored interface methods
- **THEN** CodeGen creates declaration-only `asFUNC_INTERFACE` Runtime methods without bodies or `scriptData`
- **AND** it mechanically derives declaration-order interface slots, transitive interface closure, class method-table entries, interface offsets, and interface-vtable chunks from verifier-authenticated declaration edges
- **AND** Runtime function IDs, type IDs, pointers, `vfTableIdx` values, and interface offsets remain generation-local installation state
- **AND** the complete dispatch plan is validated before the candidate module and AST snapshot are committed atomically

#### Scenario: Interface dispatch installation rolls back as one candidate
- **WHEN** interface shell creation, exact function binding, slot assignment, closure construction, offset validation, or dispatch-chunk validation fails
- **THEN** CodeGen abandons the entire candidate before module promotion
- **AND** no active type, function, method table, interface table, snapshot, generation key, or Runtime binding is patched in place
- **AND** the complete last-good generation remains current and executable

### Requirement: Shadow convergence compares isolated compiler pipelines
Migration SHALL support explicit legacy and canonical selections plus development/test-only shadow comparison in separate Engines. Shadow comparison SHALL cover compile acceptance, maintained diagnostics, VM results/exceptions, evaluation order, mutation, cleanup, dependencies, debug/coverage/timeout metadata, Cache summaries, and StaticJIT behavior. One build MUST select exactly one publishing pipeline: there is no accepted `dual` value, fact merging, or automatic canonical-to-legacy fallback. The separately selected LEGACY pipeline remains available after CANONICAL becomes default until a later dedicated retirement OpenSpec removes it.

#### Scenario: Behavioral parity permits different instructions
- **WHEN** legacy and canonical pipelines emit different Bytecode instruction sequences for the same accepted source
- **THEN** parity succeeds only if observable execution, exceptions, cleanup, metadata contracts, stable dependencies, and persistence-version rules match
- **AND** byte inequality remains available as diagnostics but is not itself a failure

#### Scenario: Semantic mismatch blocks cutover
- **WHEN** isolated legacy/canonical execution differs in result, diagnostic contract, side-effect order, cleanup, exception, route, or dependency behavior
- **THEN** canonical cutover for that milestone is blocked and legacy remains authoritative

### Requirement: Canonical frontend covers every currently accepted construct before becoming default
Before the canonical pipeline becomes the product default, every active AngelScript SDK, plugin compiler, project Script corpus, and in-scope UE integration fixture that currently compiles SHALL have a valid canonical representation and equivalent Bytecode behavior. A CANONICAL-selected build MUST fail closed rather than execute through the LEGACY semantic frontend or accept missing/invalid Canonical facts. Function-owned HIR is physically absent and is not a fallback option. The retained explicit LEGACY selection is a separate compatibility/reference build, not fallback evidence for Canonical completeness. Standalone host adaptation and Standalone Debug/Release verification are explicitly deferred to a separate future OpenSpec and are not part of this change's default-cutover gate.

#### Scenario: Accepted construct lacks canonical representation
- **WHEN** an active fixture compiles in the legacy frontend but produces an unsupported executable canonical node
- **THEN** the CANONICAL-default gate fails
- **AND** an explicitly selected CANONICAL build fails closed without invoking LEGACY

#### Scenario: StaticJIT rejects a valid canonical form
- **WHEN** canonical Sema/AST/Bytecode support a construct outside current TypedASTJIT native eligibility
- **THEN** the function remains valid and executes through BytecodeJIT/VM fallback
- **AND** this does not count as incomplete canonical frontend coverage

### Requirement: Final cutover makes Canonical default while retaining the native Legacy pipeline
After all parity gates pass, the canonical pipeline SHALL become the product default and SHALL publish only from its sealed AST. Function-owned HIR builder/accessors/capture identity are already physically absent and SHALL remain absent. The maintained fork SHALL remove all CANONICAL semantic dependence on `asCScriptNode` or `asCExprContext`. AngelScript's native syntax tree, Builder, Compiler, and an explicit LEGACY selection SHALL remain available as a separate compatibility/reference/rollback path in this change. No setting SHALL select `dual`, merge facts, or silently route an unsupported CANONICAL build through LEGACY.

#### Scenario: Final source scan proves Canonical independence
- **WHEN** the completed change is scanned and the full suite is executed
- **THEN** Bytecode and TypedASTJIT originate from canonical AST
- **AND** no CANONICAL compiler/backend path builds or consumes function-owned TypedSemantic HIR or uses `asCScriptNode` as a semantic body representation
- **AND** the native syntax AST and LEGACY compiler may remain in their explicitly selected path without satisfying any CANONICAL gate

#### Scenario: Explicit Legacy rollback is selected
- **WHEN** an operator or isolated compatibility test explicitly selects LEGACY after CANONICAL has become the default
- **THEN** the retained native Parser/`asCScriptNode`/Builder/Compiler path may publish LEGACY Bytecode
- **AND** it does not publish a Canonical AST artifact, masquerade as CANONICAL, or cause another Engine to change pipeline

#### Scenario: Old cached AST/HIR format is encountered
- **WHEN** the CANONICAL path encounters an unsupported legacy HIR/AST sidecar or compiler payload version after cutover
- **THEN** it reports a normal incompatibility/miss and recompiles from authoritative source when allowed
- **AND** it never reinterprets old bytes as the new schema

### Requirement: Compiler components preserve the host-neutral maintained-fork boundary
SourceManager, Parser, Sema, ASTContext, verifier, DTO codec, and Bytecode CodeGen SHALL remain standard-C++ maintained-fork components without Unreal container/UObject dependencies. UE Runtime SHALL consume those components through host-specific source/bind/runtime bridges. This change SHALL NOT require or claim Standalone host adoption; adapting and verifying Standalone against the completed compiler is deferred to a separate future OpenSpec.

#### Scenario: UE consumes the host-neutral canonical compiler
- **WHEN** the UE Runtime builds a CANONICAL-selected module
- **THEN** it uses the maintained standard-C++ Parser/Sema/AST/Bytecode components through the UE host bridges
- **AND** those maintained frontend/backend components do not require Unreal containers, UObjects, or Clang/LLVM libraries
- **AND** the absence of a Standalone adapter or Standalone final run does not block this change's cutover gate
