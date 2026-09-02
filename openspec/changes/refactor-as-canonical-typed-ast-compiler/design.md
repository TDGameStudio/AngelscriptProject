## Current implementation status (reconciled 2026-08-28)

The decisions below remain the target architecture and are **not yet complete
production authority**. Product compilation still defaults to LEGACY. An
explicitly selected CANONICAL `Build()` seals the pending graph and invokes
`asCBytecodeCodeGen::Generate()` before candidate-module promotion, but
residual declaration/type/scope identity bridges, lifetime/partial-
construction coverage, complete backend language coverage, product-default
cutover, and final subsystem gates remain open.

Function-owned TypedSemantic HIR is physically deleted. Its model/builder,
capture/configuration, function storage/accessors, TypedASTJIT compatibility,
Editor dump, Standalone wiring, diagnostics, and HIR-only tests are absent.
The native `asCScriptNode` syntax tree, Parser, `asCBuilder`, `asCCompiler`, and
explicit LEGACY selection remain available. Any older attachment describing
live HIR consumers or a CANONICAL product default is a historical snapshot,
not current state.

Public `CompileFunction` now follows the same authority boundary for its
single-function closure: Parser/Sema produces a sealed ephemeral graph and
`asCBytecodeCodeGen::GenerateFunction` publishes it through an attached or
detached transaction. Only this intentionally incomplete compilation mode
projects already-published current-module functions/globals into Sema as
declaration-only views; CodeGen binds them back to exact Runtime objects.
Ordinary complete-module `Build()` never sees those views, so a replacement
candidate cannot accidentally resolve against its previous generation.

`PreClassData.PropertyOffset` is now handled at the same semantic boundary.
For an exact class declaration, Sema freezes the embedding-owned storage prefix,
authored field offsets, final extent, and alignment before Seal. The Bytecode
backend consumes and validates that layout, then attaches only the Runtime
`ShadowType`/user-data links. See
`attachments/canonical-preclass-layout-gate-2026-08-24.md`.

### Interface dispatch authority and atomic publication revision (approved 2026-08-29)

Lexical interface declarations and class-to-interface dispatch SHALL follow
the same semantic-authority and publication boundary as the rest of the
Canonical graph. Sema seals exact snapshot-local method override and interface-
implementation edges. Final verification proves owner, ancestry, exact
signature, uniqueness and completeness. CodeGen then mechanically projects
those authenticated edges into generation-local Runtime function kinds,
`vfTableIdx` values, class method slots, interface closure, interface-vtable
offsets and interface dispatch chunks.

Runtime function IDs, object pointers, numeric type IDs, vtable indexes and
interface offsets are installation results, never durable Canonical identity.
An authored interface method is declaration-only `asFUNC_INTERFACE`; it has no
script body or `scriptData`. The complete interface/layout/publication plan is
validated before the existing candidate-module `Commit()` boundary. Any
missing, ambiguous, foreign, stale or inconsistent edge abandons the candidate
and leaves the last-good generation unchanged.

This revision deliberately does not widen Public AST V1. Internal immutable
inspection may expose the new semantic edges for AST-first tests and reviews;
public schema evolution remains a separately justified compatibility decision.
See
`attachments/canonical-interface-publication-transaction-design-2026-08-29.md`.

### Cache V2 scope revision (2026-08-24)

Cache V2 is no longer part of this change's production cutover critical path.
It is disabled by default and disabled Engines bypass restore, compile/Hot
Reload capture, and shutdown persistence while continuing to compile
authoritative source normally. The existing `ASTBodySidecar`, ExactStartup,
and cross-Engine work is retained as an explicitly enabled prototype, not
deleted or represented as complete. Its full remap, invocation-family, and
incremental contracts move to a later dedicated Cache V2 redesign.

### StaticJIT capture boundary revision (2026-08-28 current state)

TypedAST generation selects and leases the verified Canonical snapshot.
Preparing and freezing its authoritative source graph is independent of Cache
V2 enable/default/persistence policy. Cache V2 disabled means no restore,
publication, or persistence; it does not mean “no StaticJIT generation
snapshot.” `VerifiedTypedHIR`, function-owned HIR storage, and Provider HIR
fields are no longer transitional surfaces: they are physically absent and
must not be recreated by the lifetime work.

### Lifetime protocol revision (approved 2026-08-28)

The Clang 22.1.8 comparison found that the current Canonical implementation
mixes four responsibilities: Sema authors string/child-position cleanup facts,
publication verification checks only local expression shape, Bytecode consumes
the authored children, and TypedASTJIT privately reclassifies lifetime families
and rebuilds active-set/edge coverage. This allows one sealed graph to be
accepted by Bytecode and rejected by AOT, and it activates locals at
`DeclStmt` even though construction completes in a later initializer statement.

The approved B2 correction is normative for the remaining lifetime work:

```text
sealed Canonical semantic facts
        -> snapshot-owned versioned Canonical lifetime protocol
        -> shared deterministic transient lifetime/control view
        -> Bytecode/AOT backend-local cleanup lowering
```

Sema chooses exact lifetime subject, action target, activation/commit point,
semantic region/phase, construction step and supported exit kinds. Seal/final
publication verification authenticates the protocol. The shared derived view
mechanically proves scope edges, committed-live sets, reverse live-only order
and exactly-once; it performs no lookup, overload, conversion, type or
destructor selection. Bytecode/AOT own labels, slots, cleanup/EH stacks,
patches, tables and native frame layout. The view is not persisted, published
through Provider, read from dumps, or retained as another function-owned IR.

Existing normal/transfer cleanup statements remain during migration and are
verified against the shared view. The active exact-version Sidecar schema
remains unchanged unless an AST-first RED proves an irreducible semantic fact;
only that evidence may justify a minimal append-only revision. Full evidence
and alternatives:
`reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md`.

### Call-argument authority revision (2026-08-30)

Sema seals one immutable `asSASTCallArgument` record for every stored formal
child after overload selection, default/hidden insertion and conversion. A
direct call records its exact snapshot-local `ParamDecl`; an indirect funcdef
call records an authenticated formal ordinal and canonical formal type because
its resolved variable/parameter does not own invocation parameter declarations.
Each record also retains origin, optional authored name, source ordinal, range
and final converted expression.

Final publication verification owns one-to-one coverage, uniqueness,
origin/name/source-order consistency, direct/indirect formal ownership and
receiver shape. Bytecode CodeGen consumes those authenticated records while
Runtime parameter arrays only validate and project the current Engine ABI; it
does not reconstruct source meaning from child position or dump text. Sidecar
V9 pointer-free preserves these facts and structural identity, while V8 is an
ordinary safe miss. Public AST V1 and Cache V2 default-off policy are
unchanged. Standalone adaptation/final verification remains deferred to a
separate future OpenSpec. Evidence:
`attachments/canonical-call-argument-provenance-gate-2026-08-30.md`.

### Type-identity and Runtime-install boundary revision (2026-08-27)

The Canonical AST type model is Clang-inspired but AngelScript-native. It does
not import Clang classes, and it must not turn AngelScript's lazy Engine-local
numeric `typeId` into canonical identity. The reviewed identity model is:

```text
snapshot-local asASTTypeRef
        -> durable StableTypeKey
        -> target/profile TypeABIKey expectation
        -> generation-local RuntimeTypeBinding
        -> legacy/public numeric typeId projection where required
```

Detached AST, diagnostic, Cache-prototype, and generation inputs stop before
the generation-local layer. A candidate install resolves the complete stable
type/property/function relocation set against the candidate Engine/module,
validates ABI/layout/profile expectations, and only then publishes executable
state and its immutable Runtime resolution view together. VM execution does
not perform stable-key string/hash lookup per instruction: installed bytecode
may use already-resolved pointers, offsets, binding slots, or current public
IDs under the owning generation lease.

This change establishes and tests that boundary for canonical producers. A
later dedicated change owns the broader cleanup of legacy VM opcode operands,
`FAngelscriptPrecompiledData` numeric-ID relocation keys, optional compact slot
formats, and any public embedding API evolution. See
`reviews/type-identity-runtime-boundary-reconciliation-2026-08-27.md`.

## Context

The historical baseline had three overlapping source-level representations:

1. `asCScriptNode`, a generic token/tree node allocated from Parser `FMemStackBase` and retained by `asCBuilder` only for the current build;
2. transient `asCCompiler`/`asCExprContext` state that combines resolved types, overload/property decisions, temporaries, bytecode, and compiler control-flow state; and
3. optional function-owned `asCTypedSemanticFunction` HIR captured beside bytecode for TypedASTJIT.

The HIR proved that resolved calls, explicit conversions, argument provenance,
evaluation order, mutation single-evaluation, cleanup, transfer targets,
source provenance, and a verifier are required for source-semantic native
generation. It did not make the old Parser tree typed, and Bytecode did not
consume it. That duplicate function-owned HIR is now physically removed; its
proven semantics and tests remain requirements of the Canonical graph.

The end state is not “no possible lowering IR can ever exist” in the compiler-
theory sense. It is one canonical typed AST that owns source-level semantic
authority for CANONICAL. The completed HIR removal is a permanent boundary:
capture policy/flags, builders, node/storage types, accessors, Cache/dump
terminology, and production/test reads remain absent. A transient derived
lifetime/control view is allowed only because it is deterministically rebuilt
from a sealed snapshot, contains no independent semantic selection, and is not
persisted or published. AngelScript's native `asCScriptNode` syntax tree is a
different structure: it remains with the explicitly selected LEGACY
Parser/Builder/Compiler pipeline and is not deleted by this change.

### LEGACY retention and HIR deletion are deliberately asymmetric

- The complete native LEGACY Parser/`asCScriptNode`/Builder/Compiler pipeline is the migration oracle, syntax-coverage reference, and explicit rollback path. The native syntax tree may also continue to exist during CANONICAL parsing for grammar, recovery, locations, and parser coverage, but not as Canonical semantic input. CANONICAL prepared-module CodeGen may reuse `asCBuilder` only as the Stage 1/2 Runtime registration/transaction shell already accepted by Task 13.1; it must not walk that native tree for expression/statement meaning or invoke `asCCompiler`. LEGACY SHALL remain separately selectable after CANONICAL becomes the default in this change. This is not a production `dual` compiler: one build selects exactly one publishing pipeline, CANONICAL never silently invokes LEGACY for an unsupported node, and shadow comparisons use isolated Engines. Physical retirement, availability-policy narrowing, and source deletion belong to a later dedicated `retire-as-legacy-native-compiler-pipeline` OpenSpec.
- HIR is not AngelScript's native syntax AST and is not an independently selectable fallback compiler or backend. The duplicate function-owned source-semantic sidecar has been removed. There is no `AST -> HIR -> TypedASTJIT` compatibility stage, no reconstruction from Bytecode/Cache, and no `LifetimeHIR` replacement.
- Per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback remains a supported runtime backend policy. It consumes canonical-compiled functions and must not be confused with falling back to LEGACY Parser/Sema, `asCCompiler`, or HIR.

The primary architecture reference is the local official
`Reference/llvm-project` LLVM/Clang `22.1.8` source snapshot (tag
`llvmorg-22.1.8`; provenance in `Reference/README.md`). LLVM core has no
source-language AST; the relevant model is Clang's `SourceManager`, Parser
calling Sema actions, `ASTContext`, `Decl`/`Type`/`Stmt`/`Expr`, typed
lifetime facts, read-only CodeGen, transient cleanup stack, and on-demand
Analysis CFG. daScript remains a secondary example of a typed/normalized tree
feeding multiple backends.

This change is record-first and long-lived. Its tasks cover complete CANONICAL semantic/backend migration and HIR removal but implementation proceeds through independently verifiable milestones. No milestone in this change deletes the native LEGACY syntax AST/compiler; every migrated CANONICAL consumer still requires differential coverage before it becomes authoritative.

## Goals / Non-Goals

**Goals:**

- Establish an AngelScript-native frontend structurally equivalent to the useful Clang layers without introducing a Clang build/runtime dependency.
- Make one sealed canonical typed AST the source-level semantic authority for declarations, types, statements, expressions, Bytecode, TypedASTJIT, and public inspection whenever CANONICAL is selected. A later Cache V2 redesign may consume the stable snapshot/DTO boundary.
- Make exact lifetime action, activation/commit, semantic region/phase, construction step and supported exit-kind facts part of the sealed Canonical authority; prove edge liveness once through a shared deterministic derived view rather than duplicating Sema rules in each backend.
- Cover every currently accepted AngelScript construct in canonical Sema/AST/Bytecode by the final cutover; error recovery may use explicit invalid/error nodes that never reach executable CodeGen.
- Preserve current language, embedding, VM, UE reflection/routing, Hot Reload, debugger, coverage, timeout, and diagnostics behavior that is covered by the maintained test suite.
- Keep the existing TypedASTJIT native capability surface and per-function fallback behavior while changing only its body input from HIR to canonical AST.
- Provide a versioned public read-only AST snapshot API safe across Hot Reload and asynchronous analysis.
- Keep the existing Cache V2 prototype and its pointer-free sidecar work available behind explicit opt-in without making it a compiler-cutover dependency.
- Keep Unreal types out of the maintained frontend representation so a later Standalone refactor can reuse the completed compiler; Standalone host adaptation and final verification are deferred to a separate future OpenSpec.
- Leave a direct future lowering boundary for LLVM IR without implementing or testing an LLVM backend in this change.
- Distinguish source-semantic type identity, target/profile ABI compatibility, generation-local Runtime bindings, and the existing public numeric type-ID projection.
- Resolve canonical type/property relocations before candidate publication so no backend or active generation must perform source-name lookup in its VM hot path.
- Seal exact method override and interface-implementation edges in Sema, verify them once, and make CodeGen a mechanical generation-local Runtime dispatch/layout projection rather than a second name/signature matcher.

**Non-Goals:**

- Linking `clangAST`, `clangSema`, or other Clang libraries; copying/cutting Clang source; or adopting C/C++/Objective-C template/PCH/module complexity.
- Replacing Runtime/VM `asCDataType`, `asCTypeInfo`, GC, object layout, public type IDs, or embedding object semantics wholesale.
- Making AngelScript public `typeId` globally deterministic, hash-derived, cross-Engine, cross-generation, or durable.
- Rewriting every legacy Bytecode operand and `FAngelscriptPrecompiledData` relocation in this compiler-cutover change; that migration requires a dedicated follow-up OpenSpec.
- Physically removing AngelScript's native `asCScriptNode`, `asCBuilder`, `asCCompiler`, or explicit LEGACY selection. A later dedicated OpenSpec must separately define compatibility evidence, availability policy, rollback removal, and source deletion.
- Changing accepted AngelScript syntax or intentional language behavior.
- Requiring new Bytecode to match legacy Bytecode bytes when both satisfy the same observable behavior and versioned persistence contracts.
- Expanding TypedASTJIT to native-emit every AST node, object lifetime, container, delegate, lambda, exception-handler, suspend, Blueprint, RPC, or virtual route.
- Persisting or publishing a general CFG, cleanup stack, constructed-live bitmap, landing pad, backend active flag, or renamed lifetime HIR. The shared lifetime/control view is transient and mechanically derived.
- Claiming that semantic lifetime facts alone implement native object-frame storage, destructor/release routing, exception unwinding, or suspend/resume ABI. Unsupported native forms continue per-function fallback.
- Implementing LLVM IR lowering, ORC, object caching, executable memory, deoptimization, or an LLVM production backend.
- Publishing mutable AST nodes, AST rewriting APIs, internal arena pointers, or a stable concrete C++ node class ABI.
- Keeping a permanent production `dual` compiler or shadow-execution mode after canonical cutover.
- Completing or shipping Cache V2 cross-Engine AST restoration, invocation-family parity, function-granular incremental reuse, or a final Cache V2 persistence schema. Those belong to a later redesign change.
- Adapting, refactoring, or final-verifying the Standalone host against the completed Canonical compiler. Existing historical Standalone compatibility evidence may remain recorded, but it is not a cutover or archive gate for this change.

### Mandatory AST-first quality gate

The canonical AST is the semantic authority being migrated, so its tests are a
**preceding quality gate**, not a report generated after an end-to-end script
test happens to pass. This rule applies to every remaining change that alters
Parser actions, Sema, canonical declarations/types/expressions/statements,
sealing/verifying, canonical CodeGen inputs, or snapshot publication. The same
gate applies to Cache V2 AST reconstruction only when a later Cache-specific
change explicitly modifies that opt-in prototype.

For each semantic behavior, the implementation sequence is fixed:

```text
add a failing AST-authority test
          ↓
make the sealed canonical AST expose the intended fact
          ↓
run the focused AST gate and record its exact result
          ↓
add/run CodeGen execution and publisher-provenance coverage
          ↓
add/run Cache, reload, JIT, and broad compatibility regression when applicable
```

The AST-authority assertion must inspect the sealed canonical snapshot or a
deterministic canonical dump; it must not infer correctness merely from a
successful legacy `asCCompiler` build, a pipeline flag, or VM execution. It
asserts the smallest relevant semantic facts: declaration kind/owner/stable
key, `asCQualType` and qualifiers, value category, trait, resolved callee and
argument plan, conversion/materialization/cleanup node, control target, source
range, or diagnostic category. Snapshot and Cache work additionally asserts
lease/publication generation and pointer-free DTO fidelity before testing a
restored execution result.

The normal focused gates are:

- `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`
  for canonical semantic shape and Seal facts;
- `Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST` for parser,
  source, construction, verifier, and dump contracts;
- `Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot` for
  public immutable-snapshot and ownership contracts; and
- the default-disabled Cache boundary group for this change; opt-in Cache V2
  sidecar/restore groups are focused prototype regression evidence, not a
  canonical cutover gate.

`ProductionCodeGen` and differential/VM tests are required next, but cannot
close an AST task while the preceding AST gate is red, skipped, absent, or only
proven through legacy emission. Conversely, a green AST gate does not prove
lowering: CodeGen failures after it are classified as backend/lifecycle work,
not hidden by changing AST assertions. Every new or repaired slice records the
red test, green AST gate, and downstream result in a change attachment. The
detailed working matrix and command rules are maintained in
`attachments/ast-first-test-gate-2026-08-23.md`.

This is a **blocking task protocol**, not a preference. Before a task owner
changes production Parser/Sema/AST/CodeGen/cache/snapshot code, they must add a
gate card to the task-progress attachment using the required template. It
names one source fixture, the sealed-AST assertion, its expected red result,
and the selected owning AST suite. Only test scaffolding and diagnostic hooks
needed to observe that fact may precede the red run. A test that hand-builds an
AST is valid for arena/verifier invariants, but it cannot be the sole front
gate for a source-language behavior: that behavior also needs a Parser → Sema
→ Seal case. Once the AST gate is green, later CodeGen/VM/Cache tests may be
added without replacing or weakening it.

The complete gate-card template, task-to-suite routing, evidence states, and
completion rule are maintained in
`attachments/ast-first-gate-rollout-2026-08-23.md`. `tasks.md` section 0
normatively incorporates that attachment for all still-open compiler work.

## Decisions

### 1. Adopt the Clang frontend shape with AngelScript-native nodes

The target pipeline is:

```text
asCSourceManager
       |
       v
asCParser ---- Sema actions ----> asCSema
                                      |
                                      v
                                 asCASTContext
                     Decl / Type / QualType / Stmt / Expr
                                      |
                 +--------------------+--------------------+
                 |                    |                    |
                 v                    v                    v
        asCBytecodeCodeGen   FAngelscriptTypedASTJIT   public/cache views
```

Parser recognizes grammar and supplies source syntax to Sema actions. Sema performs lookup, overload resolution, conversion selection, access checks, function/property rewrites, argument planning, and lifetime analysis before constructing final typed nodes. Backends do not redo Sema.

Internal implementation may use arena raw pointers, compact tagged hierarchies, `isa/cast`-style helpers, trailing storage, non-owning arrays, and batch lifetime like Clang. It MUST NOT make every node independently heap-owned, reference counted, virtual, or writable by backends.

Alternative rejected: link or reuse concrete Clang AST classes. They encode C-family semantics, pull a large dependency graph, and do not model AngelScript handles, references, imports, bindings, VM execution, UE routes, or Cache V2 identity.

Alternative rejected: add type and CodeGen fields directly to `asCScriptNode`. A universal optional-field node would preserve the present phase coupling and make Parser-created objects carry backend state.

### 2. SourceManager owns source identity and mapping

`asCSourceManager` owns source-file/section identities and maps authored, preprocessed, generated, and logical source coordinates. AST nodes store compact `asCSourceLocation`/`asCSourceRange`; they do not own section strings or retain arbitrary token buffers.

Source identities distinguish stable logical identity from process-local file/table indices. Cache/public views serialize stable logical source keys and offsets, then remap them to snapshot-local source IDs. Diagnostics continue using existing section/row/column behavior derived from SourceManager.

Locked encoding (see `attachments/llvm-ast-architecture.md`): `asASTFileID` 0 is invalid; `asCSourceLocation` is `{fileID, 32-bit byte offset}`; ranges are half-open `[begin, end)`; origins are authored/processed/generated. This follows Clang's SourceManager/FileID split without 16-bit packed SLocEntry compression, because AngelScript sections can exceed 64 KiB.

### 3. ASTContext is module-owned and nodes are sealed

One live `asCASTContext` owns a module translation-unit declaration, declaration/type tables, and compiled function bodies. It provides arena allocation, canonical type interning, snapshot-local IDs, source tables, verification, deterministic dumping, and sealing.

The minimum internal hierarchy is:

```text
asCDecl
  TranslationUnitDecl, NamespaceDecl, TypeDecl, ClassDecl, InterfaceDecl,
  EnumDecl, FuncDefDecl, FunctionDecl, MethodDecl, ConstructorDecl,
  DestructorDecl, VarDecl, ParamDecl, PropertyDecl, ImportDecl

asCType / asCQualType
  primitive, enum, funcdef, value object, reference object, array/template,
  const, reference, handle, auto-handle, in/out/inout, canonical identity

asCStmt
  block, declaration, expression, if, for, while, do-while, switch/case,
  break, continue, return, try/error-recovery where accepted/rejected

asCExpr
  literal, declaration reference, member/property reference, call,
  construction, conversion, unary/binary/logical/conditional, assignment,
  sequence/single-evaluation, temporary materialization, cleanup, error
```

Every executable expression has an exact `asCQualType`, value category, source
range, and explicit resolved semantics. Implicit conversions, compiler-
generated calls, default/hidden arguments, property rewrites, materialized
temporaries, exact cleanup actions, lifetime activation/extension facts,
semantic regions/phases, construction steps and control-transfer targets are
Canonical facts rather than backend inference. This does not require a copy of
the fully expanded reverse cleanup list to be stored as ordinary children on
every control-flow edge.

Nodes may be mutable only while Sema owns the unsealed context. Successful module compilation seals and verifies the snapshot. Published, cached, or backend-visible nodes are immutable.

### 3A. AST observability is a compiler subsystem, not ad-hoc test output

The canonical AST cannot become the semantic authority if its only practical
debug interface is a flat all-node string. Following the useful parts of
Clang's `RecursiveASTVisitor`, `ParentMapContext`, text/JSON AST dump,
`clang-check` dump filtering, AST Matchers, structural-equivalence/import
diagnostics, and on-demand CFG model, this change provides an AngelScript-native
read-only tooling layer. It does not link or copy Clang.

The pre-cutover tooling contract is:

- one generic const traversal API over Decl/Type/Stmt/Expr with explicit named
  edge roles, deterministic pre/post order, depth/budget guards, and no backend
  state;
- an on-demand snapshot-local parent/edge index derived from the sealed graph,
  rather than mutable parent pointers added to every expression;
- stable flat compatibility output plus tree text and machine-readable JSON,
  filtered by module, stable declaration key, node ID/kind, and logical source;
- verifier failures that identify the offending node, edge and related target,
  resolve line/column/source snippets, and show a deterministic root-to-node
  path/local subtree;
- a small AngelScript-specific matcher/assertion/query layer for AST-first
  tests and a complete semantic graph diff. This is intentionally smaller than
  Clang's generated dynamic AST Matcher DSL;
- developer/commandlet diagnostics that acquire an immutable snapshot lease
  before list/dump/query/verify/diff operations. Tool output is diagnostic only
  and is never accepted as Cache V2 or compiler input.

Clang PCH/module serialization and general `ASTImporter` are not copied. Cache
V2 keeps its versioned pointer-free DTO and explicit target-Engine remap.
General typed CFG text/DOT, SSA and data-flow optimization remain second-stage
tools. The bounded shared lifetime/control view approved below is part of this
change because verifier and both backends already need the same liveness/edge
proof. It is not permission for a backend to bypass structured AST/protocol
facts and is not a persistence format.

### 3B. Canonical lifetime protocol separates semantics, proof, and lowering

Clang 22.1.8 provides the behavioral model but not the exact storage model for
this multi-backend product. Clang AST stores resolved construction,
temporary/materialization, destructor and lifetime-extension facts; Analysis
CFG optionally derives implicit destructor/lifetime elements; CodeGen pushes
an active cleanup only after initialization succeeds. It does not serialize an
initializer-abort cleanup plan. AngelScript adopts the success/commit and
reverse-live-prefix semantics while adding one snapshot-owned protocol so
Bytecode and AOT do not independently rerun lifetime Sema.

The Canonical lifetime protocol is part of the sealed snapshot and has an
explicit internal revision. Its minimum semantic records are:

```text
LifetimeRecord
  subject declaration/storage identity
  exact qualified type
  action kind and exact destructor/release target
  owner scope or named phase
  activation/commit-on-success point
  normal lifetime end
  reviewed normal/exception/abort applicability
  optional exceptional region and source range

ConstructionRecord
  owner object and construction kind
  ordered virtual-base/base/field/element/delegating steps
  step commit points and complete-object commit
  optional pointer-free dynamic progress identity

Region/PhaseRecord
  exact owner statement/expression and parent region
  named control/lifetime role and supported exits
```

The protocol uses snapshot-local IDs only under the owning snapshot lease. Any
future DTO or cross-generation representation remaps to complete stable keys,
logical source coordinates and an explicit protocol/schema revision. It never
stores Engine pointers, numeric TypeIds, backend slots, native frame offsets,
LLVM values, labels or patch locations.

A single shared derived lifetime/control view walks the sealed statement graph
and protocol in execution order. It computes scope/phase nesting, successor and
exit roles, committed-live sets and exact reverse cleanup sequences. It
verifies missing, duplicate, wrong-order, wrong-target and double-cleanup
cases; an initializer failure sees only strictly earlier committed actions,
the current failing action is absent, and a complete-object destructor is
reachable only after complete-object commit. Dynamic arrays/aggregates use a
validated progress count/cursor rather than treating the whole object as live.

This view is transient, deterministic and rebuildable. It performs no symbol
lookup, overload/conversion selection, type classification or destructor
search; it never writes back to the sealed graph, enters Public AST/Cache/
Provider/detached artifacts, or parses dump output. Verifier, Bytecode
admission, AOT eligibility and tests share its interpretation. AOT may retain
extra conservative capability checks but may not select different semantic
actions.

Bytecode and AOT continue to own backend-local cleanup/EH stacks, block labels,
branch patches, stack/local slots, active flags, constructed counters,
physical exception tables, block sharing and native frame ABI. They lower the
verified protocol; they do not invent or replace it.

During migration, existing `scope-exit`/`scope-release` normal and transfer
cleanup statements remain executable inputs. The shared view verifies their
exact equivalence to the protocol before publication. Once all consumers use
the typed contract, string literals and positional foreach cleanup children may
be removed in a separately reviewed slice without changing language behavior.

Alternative rejected: persist one expanded cleanup list on every CFG edge.
This duplicates data, scales poorly to partial arrays and conditional
activation, and has already produced producer/verifier/backend drift.

Alternative rejected: pure backend cleanup inference. Clang can centralize
this in one LLVM CodeGen, but AngelScript has Bytecode, AOT, verification,
snapshot and Provider consumers; independent inference violates the sealed
semantic-authority boundary.

Alternative rejected: persisted CFG or `LifetimeHIR`. It recreates a second
function-owned semantic representation and reverses the completed HIR removal.

### 4. Sema becomes the only semantic authority

`asCSema` owns:

- declaration registration and scope/namespace lookup;
- canonical type construction and qualifier checks;
- overload, constructor, conversion, operator, property, and mixin resolution;
- argument origins, hidden/default arguments, effective receivers, and ABI-independent call shape;
- reference/handle/value categories and assignability;
- temporary construction, materialization, exact cleanup action selection,
  lifetime activation/extension, construction commit and supported exceptional
  region facts;
- global/import/dependency provenance and stable target references;
- loop/switch phases and verified `break`/`continue`/`return` targets;
- diagnostic emission and explicit error/recovery nodes.

CANONICAL Sema/AST/CodeGen does not store Bytecode or native temporaries and does not depend on `asCExprContext`. The retained LEGACY compiler may continue to own its existing `asCExprContext::bc` implementation. HIR-sidecar identity is already physically absent from both paths and must not be restored.

### 4A. Sema owns override/interface decisions; CodeGen owns Runtime slots

The approved interface-dispatch model follows the same ownership split that
Clang uses between semantic method relationships and ABI vtable construction,
without importing Clang C++ ABI machinery. Canonical Sema resolves and seals:

- the exact overridden or implemented method declaration for every authored
  method edge, using snapshot-local declaration identity rather than spelling;
- the declaring interface/class owner and complete transitive ancestry needed
  to prove that the edge is legal;
- the already-canonical exact signature, qualifiers, return type and parameter
  types used by the relationship;
- whether each concrete class satisfies every required interface method,
  including inherited implementations, or must fail before publication.

The final verifier authenticates that every target exists in the same sealed
snapshot, is the right declaration kind, belongs to a valid base/interface
closure, has the exact compatible signature, appears at most once in the
applicable slot, and leaves no required interface method unresolved. These are
semantic facts. CodeGen MUST NOT repeat overload lookup or choose a target by
method name/signature.

After verification, CodeGen constructs a transient generation-local dispatch
plan. It creates declaration-only Runtime interface shells and
`asFUNC_INTERFACE` methods, assigns their own declaration-order `vfTableIdx`,
derives transitive interface closure and offsets, maps each authenticated Sema
edge to the exact candidate Runtime function, and emits class method-table and
interface-vtable chunks. The plan may contain Runtime pointers, function IDs,
numeric type IDs, indexes and offsets only while owned by the candidate
generation. None of those values become Canonical, public, cache, diagnostic or
cross-generation identity.

All semantic and layout validation occurs before candidate publication. The
existing detached `Commit()`/`Abandon()` transaction and module-candidate
promotion remain the atomic boundary: no active type, function, method slot,
interface chunk, snapshot or Runtime binding is patched incrementally after
promotion. Public AST V1 is unchanged in this slice; internal immutable
dump/query/traversal surfaces expose the exact semantic edges for testing.

Alternatives rejected:

- backend name/signature re-matching, because it reruns Sema and can disagree
  with the sealed graph;
- reusing `asCBuilder` interface metadata, because it imports native-tree
  semantic authority into CANONICAL and weakens candidate isolation;
- post-promotion Runtime patching, because failure could publish a partial
  generation;
- storing Runtime slots/offsets in Canonical AST, because they are Engine- and
  generation-local installation results.

### 5. QualType is an AST type system with a Runtime bridge

The frontend introduces canonical `asCType` plus compact `asCQualType`. It captures source-semantic identity and qualifiers without embedding `asCTypeInfo*` in public/cache identity.

`asCQualType` is a snapshot-local `asASTTypeRef` plus a packed qualifier mask (const, handle, auto-handle, reference, in/out/inout). Canonical types are interned in `asCASTContext`. Internal node tables use 1-based opaque IDs rather than public arena pointers, so Cache V1 DTOs, Hot Reload leases, and `asIASTSnapshot` share one numbering scheme (Clang uses pointers internally; we keep pointers out of every durable/public surface).

The type system deliberately separates five roles that the legacy compiler often
represented through one `asCDataType`/numeric-ID path:

1. **`asASTTypeRef` is snapshot-local identity.** It is compact and interned,
   but it is meaningless outside its owning `asCASTContext` and MUST NOT be
   compared across snapshots or persisted as global identity.
2. **`StableTypeKey` is durable source-semantic identity.** It includes type
   kind plus canonical nominal declaration/template structure; qualifiers stay
   in `asCQualType`. Hashes may index this identity but never replace complete
   key equality. Public V1 may expose its deterministic spelling while concrete
   internal key tables remain private.
3. **`TypeABIKey` is target/runtime compatibility.** It combines the stable
   semantic identity with target profile, native environment and every
   layout/calling/lifetime fact needed by the consumer. Two Hot Reload
   generations may share a StableTypeKey and still have different ABI keys.
4. **`RuntimeTypeBinding` is generation-local installation state.** It resolves
   one stable/ABI expectation to the candidate Engine's `asCDataType`,
   `asCTypeInfo*`, layout, behaviours, property/function bindings and current
   public type ID. It is immutable after publication and dies only with the
   owning module/function generation lease.
5. **Numeric `typeId` is a legacy/public projection.** Primitive IDs retain
   their existing fixed values; object IDs remain lazy and Engine-local. They
   are valid for public embedding APIs and bytecode operations that explicitly
   expose the current ID, but are never canonical, cross-Engine,
   cross-generation, Cache, Provider or relocation identity.

`asCRuntimeTypeBridge` is the live resolver for this boundary. During Sema and
detached CodeGen it may read candidate transient types before publication, but
it cannot publish a bare resolved pointer/ID into a durable surface. The
detached artifact carries stable type/property/function relocation records and
expected ABI keys. Candidate installation resolves the complete set, rejects
missing, ambiguous or ABI/layout-incompatible bindings before mutation, and
then either patches active bytecode to already-resolved pointers/offsets/IDs or
publishes an immutable generation-local binding table.

This keeps dynamic work out of the VM hot path. Type-bearing legacy bytecodes
fall into three reviewed categories:

- metadata-only operands such as `COPY` type metadata and property-owner IDs
  used by `ADDSi`/`LoadThisR`; active VM execution needs only size/offset;
- Runtime type targets such as `Cast`, which may use an installed type pointer
  or generation-local slot rather than stable-key lookup per execution; and
- language/public-ID projections such as `TYPEID` and `SetListType`, which
  materialize the owning generation's current numeric ID.

The current change must prevent new canonical/durable artifacts from treating
the numeric ID as a symbol. It does not need to redesign every legacy opcode to
close the compiler cutover. A follow-up change will migrate legacy
`FAngelscriptPrecompiledData` type/property references away from old numeric
IDs, remove metadata-only IDs where safe, choose pointer-versus-slot active
forms, and add any bytecode/schema version transition.

Alternative rejected: deterministic eager type-ID allocation. Registration
sets/order change between hosts, and Hot Reload requires old and new revisions
to coexist.

Alternative rejected: hash-derived public type IDs. Existing flags leave a
limited numeric payload, collisions remain possible, and one semantic name may
have multiple live ABI revisions.

Alternative rejected: persist direct `asCTypeInfo*` like an in-process
daScript `TypeInfo*`. Direct pointers are useful after installation but cannot
cross Engine, Cache, Provider, or generation lifetime boundaries.

Alternative rejected: replace the entire Runtime type system in the same
change. That would combine frontend migration with VM/GC/object-layout/public
embedding redesign and remove the ability to establish behavior parity
incrementally.

### 6. Public AST V1 is an immutable opaque snapshot API

The public API is explicitly versioned and does not expose internal nodes:

```cpp
enum asEASTRetentionPolicy
{
    asAST_DISCARD_AFTER_CODEGEN = 0,
    asAST_RETAIN_SNAPSHOT = 1,
};

class asIASTSnapshot
{
public:
    virtual int AddRef() const = 0;
    virtual int Release() const = 0;
    virtual asDWORD GetAPIVersion() const = 0;
    virtual const char* GetModuleName() const = 0;
    virtual const char* GetGenerationKey() const = 0;
    virtual bool IsCurrentGeneration() const = 0;
    virtual asASTDeclId GetTranslationUnitDecl() const = 0;
    virtual int GetDecl(asASTDeclId, asSASTDeclView*) const = 0;
    virtual int GetStmt(asASTStmtId, asSASTStmtView*) const = 0;
    virtual int GetExpr(asASTExprId, asSASTExprView*) const = 0;
    virtual int GetType(asASTTypeRef, asSASTTypeView*) const = 0;
protected:
    virtual ~asIASTSnapshot() {}
};
```

`asIScriptModule` adds:

```cpp
virtual int SetASTRetentionPolicy(asEASTRetentionPolicy policy) = 0;
virtual asEASTRetentionPolicy GetASTRetentionPolicy() const = 0;
virtual asIASTSnapshot* AcquireASTSnapshot(asDWORD apiVersion) const = 0;
```

The retention policy freezes when `Build()` starts. A built module rejects in-place policy changes; callers discard/rebuild or create another module. `AcquireASTSnapshot` returns an AddRef-owned immutable snapshot or null/unavailable when no retained/restored AST exists or the requested version is unsupported.

`asASTDeclId`, `asASTStmtId`, `asASTExprId`, and `asASTTypeRef` are opaque and valid only within one snapshot. Every POD view begins with `structSize` and `apiVersion` and exposes kind, source range, exact public type/value category, child IDs, and stable declaration/type keys as applicable. It never exposes internal C++ node addresses, `asCTypeInfo*`, `asCScriptFunction*`, Engine-local numeric FunctionId, or writable storage.

V1 remains available after later versions appear; incompatible growth uses a parallel API version and size/version-gated views instead of changing concrete internal layouts.

### 7. Retention is module-local and lease-safe across Hot Reload

Every source build constructs the canonical AST because Bytecode consumes it. After CodeGen:

- `asAST_DISCARD_AFTER_CODEGEN` may release function-body nodes and does not publish a public snapshot;
- `asAST_RETAIN_SNAPSHOT` publishes the complete sealed module snapshot for StaticJIT, diagnostics, Cache V2, and public readers.

Hot Reload compiles and verifies a replacement module/context off to the side, then atomically publishes the new module and snapshot. Existing readers keep old snapshot storage alive through AddRef leases. `IsCurrentGeneration()` becomes false after replacement; old snapshots stay internally consistent and do not resolve through mutable current-module pointers.

Cross-module AST references are stable declaration/type keys with an optional Engine-local resolved view held by the current generation. They are not arena pointers into another snapshot. Runtime type/property bindings are immutable members of the same generation aggregate; a new generation builds new bindings instead of retargeting an old slot. The last lease releases source tables, nodes, stable-reference tables, Runtime resolution views, and any old type-ID map dependencies together.

### 8. Cache V2 is a default-disabled, retained prototype boundary

The current Cache V2 prototype continues to use SourceIndex, ModuleInterface,
TypeSchema, ModuleState, FunctionBody, DebugSidecar, and atomic ModuleSnapshot
assembly. Its canonical AST experiment uses versioned records instead of a
monolithic memory image:

- source, declaration, type, and global reconstruction data aligns with SourceIndex, ModuleInterface, TypeSchema, and ModuleState;
- a FunctionBody may link an optional `ASTBodySidecar` containing pointer-free function-body nodes and stable references;
- all record links include owner keys, profile/schema versions, content hashes, and canonical absence coordinates;
- live numeric IDs and pointers are assigned only after validation/remap in the target Engine;
- encoded type/property identity uses stable keys plus explicit compatibility data, never publishing-Engine numeric `typeId`, pointer, snapshot-local `asASTTypeRef`, or a hash without complete-key verification.

These rules describe the retained opt-in prototype. They do not claim complete
cross-Engine restoration. Explicitly enabled ExactStartup continues to reject
missing/corrupt/mismatched fragments before Engine mutation.

With product defaults, Cache V2 is disabled: startup performs no ExactStartup,
source and Hot Reload compiles create no Cache capture transaction, and shutdown
persists no Cache generation. The ordinary compiler path remains authoritative.
Function-granular incremental AST reuse and complete target-Engine remap are
deferred to the later Cache V2 redesign rather than inferred from the existing
module-shared sidecar prototype.

`SaveByteCode`, VM FunctionBody bytes, public AST dumps, `.hir.txt`, and `.hir.json` are not AST persistence inputs. The unimplemented `TypedHIRSidecar` name/schema is replaced before any record kind is published.

### 9. Bytecode becomes a read-only AST backend

`asCBytecodeCodeGen` consumes Frozen/Publishable declarations, bodies and the
verifier-authenticated lifetime protocol/shared view. It owns all VM stack
slots, temporary registers, labels, patch lists, backend cleanup/EH stacks,
exception tables, debug position emission, safe points, dependency
relocations, and final bytecode buffers. It may query the Runtime type bridge
but cannot perform overload selection, insert an unrecorded conversion, select
a new cleanup action, reinterpret an invalid/missing protocol as no-cleanup, or
repeat lifetime-family/destructor classification. It may mechanically derive
branch routing, active flags and shared cleanup blocks from the verified
protocol.

Before module mutation, CodeGen produces a detached artifact whose durable
type/property/function references are stable symbolic relocations with expected
target/profile ABI compatibility. Candidate installation resolves every
relocation against the candidate Engine/module and constructs the immutable
generation-local Runtime resolution view. Only after complete resolution and
snapshot verification may publication patch active bytecode operands or expose
the new executable generation. A missing, ambiguous, stale, or ABI/layout-
incompatible binding fails before mutation and preserves the last good
executable, snapshot, identity, and Runtime bindings.

Active bytecode is allowed to contain generation-local `asCTypeInfo*`, property
offsets, compact slots, or current numeric type IDs when the instruction's VM
or public ABI requires them. These values are execution representations under
the generation lease; they are not copied into Public AST, diagnostic dumps,
Cache DTOs, StaticJIT Provider identity, or cross-generation relocation keys.

Lexical interfaces use the same detached boundary. CodeGen creates interface
Runtime methods as declaration-only `asFUNC_INTERFACE` objects and consumes
only verifier-authenticated method edges to build class method-table and
interface-vtable projections. A bodyless interface declaration is not silently
converted into `asFUNC_SCRIPT`, and CodeGen does not manufacture `scriptData`
or source-body metadata for it. The complete interface closure, slot plan,
offset plan and function binding set must validate before `Commit()`; any
failure abandons the candidate without changing the current module generation.

During migration, legacy and canonical pipelines compile the same fixtures in separate Engines. Acceptance is based on:

- compile success/failure and maintained diagnostics;
- VM observable results and exceptions;
- argument/evaluation order and mutation single-evaluation;
- cleanup/destructor and global/import behavior;
- debugger/coverage/timeout metadata contracts;
- stable dependency and Cache V2 summaries.

Byte-for-byte instruction equality is diagnostic evidence, not a cutover requirement. SaveByteCode/Cache readers use explicit payload/schema versions and reject unsupported content safely.

### 10. TypedASTJIT migrates without widening native eligibility

`FAngelscriptTypedASTJIT` reads the internal Frozen/Publishable AST snapshot,
the verifier-authenticated lifetime protocol/shared view and the immutable
Runtime binding snapshot. It shares no body IR with BytecodeJIT. Historical HIR
analysis/emission behavior is represented by equivalent Canonical nodes and
protocol facts while preserving:

- source/root selection and complete call-closure validation;
- argument order, effective receivers, mutation plans, cleanup, recursion budgets, exception metadata, and semantic dependencies;
- native-call linkage/bridge decisions and Unreal route safety;
- Provider VM/Raw/Parms entry shapes and leases;
- per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback;
- no production `dual` backend.

TypedASTJIT may publish only pointer-free lifetime summaries copied under the
snapshot lease. It must not scan declarations by stable/display name to select
a destructor, reclassify release/destructor families from type kind, infer
activation at `DeclStmt`, or retain an AST/protocol pointer in Provider state.
Missing, invalid, unsupported-exit or native-object-frame facts are typed
per-function fallback, never `VerifiedEmpty`.

Forms outside current TypedASTJIT eligibility remain typed AST nodes and still compile to Bytecode; they do not justify a legacy frontend or HIR fallback.

### 11. Primary Generate and native forms are absorbed from the superseded change

Matching-profile Editor Generate reads the current primary Engine's immutable compiled graph and retained AST snapshot after a freshness gate. It does not create a sibling generation Engine, force-clean, compile, reload, reinstance, or mutate primary packages/routes/registries.

Non-matching Editor profiles and isolated commandlets use exactly one contained generation Engine at a time, compile the complete source graph for that profile, retain its canonical AST for generation, emit only the selected module set, and destroy request-owned state afterward.

Native bind replay remains per Engine. A process-global, stable-declaration-keyed native-form recipe catalog records reviewed HeaderInline/module-exported/bridge metadata after real declaration registration, so matching-profile Generate does not need a sibling Engine solely to retain pointer-keyed native forms. Missing/unproven recipes degrade to bridge/fallback.

Generate freezes Hot Reload queue application for the request. Success and every early-fail path preserve primary package, reflection, route, cache, UObject/CDO, delegate, world, and pooled-context ownership except explicitly owned output files.

### 12. Shadow convergence is the migration mechanism, not the final architecture

The same OpenSpec carries the complete migration, but the implementation advances through gates:

1. freeze legacy/HIR-era/VM/StaticJIT semantic oracles;
2. introduce SourceManager, ASTContext, node/type IDs, verifier, and dump;
3. shadow-build declaration/type AST;
4. shadow-build complete expression/statement/lifetime AST;
5. publish public snapshots and preserve the existing Cache V2 DTO prototype behind explicit opt-in;
6. move TypedASTJIT to canonical AST and physically remove function-owned HIR;
7. introduce the versioned Canonical lifetime protocol/shared derived view,
   verify existing cleanup statements against it, and close local/subobject/
   aggregate partial construction before widening native object eligibility;
8. complete canonical BytecodeCodeGen and differential execution;
9. make the canonical pipeline the default while retaining explicit LEGACY
   selection as an independent compatibility/reference path;
10. remove every remaining CANONICAL semantic dependency on `asCScriptNode`;
    retain the native syntax tree and LEGACY Parser/Builder/Compiler for the
    later retirement change.

No milestone may use partial canonical AST as executable authority. Before CANONICAL becomes default, unsupported canonical compilation fails closed while an explicitly selected LEGACY Engine remains available separately; there is no automatic fallback or fact merging. Default cutover requires canonical coverage for every active language/SDK/compiler fixture; only explicitly invalid/error-recovery nodes may remain non-executable.

Alternative rejected: big-bang replacement. It removes the only practical oracle for a 20k+ line mixed compiler and makes language, VM, UE, cache, and StaticJIT regressions inseparable.

Alternative rejected: wrap current HIR as the public AST. It would freeze function-owned sidecar shape, retain duplicate declaration syntax, and preserve Engine-local type/function identity problems.

### 13. LLVM readiness is a boundary constraint only

Canonical AST must contain all language semantics needed for lowering without decoding Bytecode or re-running Sema: exact types/value categories, resolved declarations/calls, explicit conversions, sequencing, temporaries, cleanup, control targets, source locations, and stable dependencies.

Backend state is isolated. This change includes only the bounded shared
derived lifetime/control view required to verify cleanup and partial
construction consistently; it is not a general CFG, public/compiler transport,
SSA or optimization framework. A general on-demand typed CFG may be added
later for broader analysis/data-flow work. No LLVM type, `llvm::Value*`, LLVM
ownership, pass pipeline, object cache, ORC API, or LLVM test appears in this
change.

## Risks / Trade-offs

- [One change spans a long migration] -> Keep tasks milestone-grouped, require each gate to be independently buildable/testable, and rewrite later tasks when evidence changes without splitting semantic authority across competing OpenSpecs.
- [Shadow construction doubles compile work and memory] -> Restrict same-build shadow construction to development/test profiles and remove it after canonical cutover. Retaining two explicitly selected independent pipelines is not authorization to compile both or auto-fallback in one production build.
- [Public API freezes immature details] -> Publish only opaque IDs and size/versioned views, retain V1, and keep concrete node classes private.
- [Retained AST increases Editor memory] -> Make retention module/profile-specific, discard bodies after CodeGen by default, expose counters, and keep Shipping VM-only profiles capture-off.
- [Old snapshots outlive current Engine objects] -> Store stable keys and snapshot-owned data publicly; isolate Engine-local resolved views and release them with generation leases.
- [Dynamic public type IDs leak into canonical identity] -> Treat numeric IDs as current-Engine projections only; persist stable keys plus explicit ABI/layout compatibility and resolve before publication.
- [Runtime resolution adds VM hot-path lookup] -> Resolve the complete relocation set once during candidate installation, then execute through patched pointers/offsets/IDs or immutable generation-local slots.
- [Stable type spelling aliases incompatible generations] -> Separate semantic StableTypeKey from target/profile TypeABIKey and never retarget a published generation's binding table.
- [Cache sidecars diverge from live AST] -> Encode/decode through a separate DTO, deterministic round-trip tests, verifier after remap, content hashes, and miss-before-mutation.
- [New Bytecode changes instruction shape] -> Compare observable execution/metadata in separate Engines, version persisted payloads, and retain legacy path until the complete parity gate passes.
- [Sema extraction changes diagnostics] -> Keep exact diagnostic regression fixtures and source-range tests; intentional changes require explicit spec/test updates rather than incidental churn.
- [TypedASTJIT loses supported forms] -> Preserve migrated HIR-era semantic expectations as Canonical generated-output/differential fixtures and keep unsupported native forms on typed per-function fallback.
- [Lifetime semantics drift across Sema, verifier, Bytecode and AOT] -> Select exact actions/activation/regions once in the sealed protocol; share one derived edge/liveness verifier; forbid backend destructor/type-family inference.
- [The shared lifetime view becomes a renamed HIR] -> Keep it transient, deterministic and rebuildable; expose no persistence/Provider/Public ABI; store no backend labels/slots/frames; add forbidden-symbol and transport-boundary tests.
- [Partial construction destroys an uncommitted object] -> Model success commit points and complete-object commit explicitly; derive failure cleanup from only the strictly earlier committed prefix; use a bounded progress identity for arrays/aggregates.
- [Sidecar schema churn duplicates derived state] -> Keep the active exact-version schema when facts are reconstructible; require an AST-first RED before adding an irreducible semantic field; never persist expanded edge lists or backend cleanup state.
- [Clang model is copied too literally] -> Use only ownership/layering/implicit-node principles; exclude C++ templates, PCH, macro-generated hierarchy breadth, and unrelated language modes.
- [Primary Generate races Hot Reload] -> Freeze application, acquire immutable inventory/AST leases, freshness-check before output, and queue changes for normal processing afterward.
- [Native-form catalog aliases declarations] -> Key by stable declaration identity plus target/bind profile and validate ABI/linkage/route metadata at lookup.
- [CodeGen re-matches an interface method by spelling] -> Seal the exact method edge in Sema, authenticate it in the final verifier, and require CodeGen to consume declaration identity only.
- [Interface shell is published with script-function body state] -> Make authored interface methods declaration-only `asFUNC_INTERFACE`, reject body/scriptData ownership, and validate function kind before candidate commit.
- [Interface slot/layout failure leaks a partial generation] -> Build and validate the complete transient dispatch plan before `Commit()`; use `Abandon()` and candidate promotion to preserve the last-good module, types, snapshot and Runtime binding view.
- [Runtime vtable indexes become durable AST identity] -> Keep `vfTableIdx`, interface offsets, numeric IDs and Runtime pointers generation-local; Canonical edges use snapshot-local declaration identity and stable cross-generation keys only where needed.

## Migration Plan

1. Record normalized baseline dumps and differential fixtures for Parser shape, declarations, Sema decisions, HIR, Bytecode behavior, diagnostics, cleanup, dependencies, and TypedASTJIT. Establish the AST-first gate for each remaining semantic slice before its lowering work begins.
2. Add SourceManager, ASTContext, snapshot-local IDs, stable type keys, verifier, deterministic dumper, and shadow-only creation behind an internal development/test pipeline selection. Freeze the distinction between semantic keys, ABI compatibility, Runtime bindings, and public numeric IDs before adding more artifact consumers.
3. Move declaration/type/namespace/default/import registration into Parser-to-Sema actions while retaining legacy builder results as the comparison authority. Seal and verify exact class/interface method relationships before mechanically projecting generation-local Runtime slots and interface chunks. Add detached-artifact type/property/function relocation tests plus candidate-install failure injection before treating canonical CodeGen output as publishable.
4. Move expression, statement, call, property, argument, temporary, cleanup,
   activation/commit, construction and control semantics into sealed Canonical
   facts until all accepted fixtures verify without native-node semantic replay.
5. Add public AST V1, module retention, Hot Reload snapshot publication/leases, and canonical diagnostic dumping.
6. Make Cache V2 default-off and prove the disabled path compiles authoritative source without restore/capture/persistence; retain existing round-trip/ExactStartup tests as non-blocking prototype evidence.
7. Keep the completed HIR retirement closed and port remaining TypedASTJIT
   eligibility/dependency/lifetime behavior to Canonical facts while retaining
   BytecodeJIT/VM fallback.
8. Add the Canonical lifetime protocol/shared derived view; first prove local
   initializer success activation, then base/member/delegating committed
   prefixes and array/aggregate progress; keep unknown exception/suspend forms
   fail-closed.
9. Complete read-only BytecodeCodeGen and AOT protocol consumption, compare
   legacy/canonical behavior in isolated Engines, and make canonical the default
   only after focused and full parity gates pass.
10. Prove CANONICAL Sema and both CANONICAL backends do not semantically
    consume `asCScriptNode`; preserve the native syntax tree, parser tests,
    Builder, Compiler, and explicit LEGACY selection for the later retirement
    OpenSpec.
11. Update public/fork/cache/StaticJIT documentation, record the separate
    future Standalone boundary, run final source scans and full in-scope project
    validation, then archive this change only when all in-scope tasks are
    actually complete.

Rollback after CANONICAL becomes default explicitly selects the retained verified LEGACY compiler path and ignores canonical AST sidecars through normal version/eligibility misses. This is an explicit pipeline choice, never runtime reinterpretation of incompatible payloads, same-build dual compilation, or automatic fallback. A later native-compiler retirement OpenSpec must replace this rollback contract before it may delete the old path.

## Open Questions

No blocking architecture decision remains for recording this change. The B2
Canonical lifetime protocol/shared transient view is approved. Its exact
internal type names and whether an irreducible new semantic field requires a
Sidecar revision remain evidence-driven implementation details. Preserve the
active exact-version schema unless an AST-first RED proves deterministic
reconstruction insufficient.

Approach A for lexical interface dispatch/publication is also approved. Sema
owns exact method override/implementation edges; the final verifier owns their
structural and semantic authentication; CodeGen owns only the transient
generation-local Runtime slot/layout projection; and candidate `Commit()` is
the sole publication point. Internal type names and compact storage shape are
implementation details, but replacing exact edges with backend matching,
Builder metadata, post-publication patching, or durable Runtime indexes requires
an explicit design revision. Public AST V1 remains unchanged by this slice.

Changing the public V1 contract, behavior-compatibility target, Clang-style
phase boundaries, B2 semantic/proof/lowering split, type-identity/Runtime-
install split, LLVM non-goal, completed HIR removal, retained native LEGACY
AST/compiler boundary, or Cache V2 default-off boundary requires an explicit
design/spec revision. A production Cache V2 redesign, full legacy VM/
PrecompiledData type-relocation migration, and native LEGACY compiler
retirement each require their own change rather than silently expanding this
compiler cutover. Recommended follow-up names are
`refactor-as-runtime-type-identity-relocation` and
`retire-as-legacy-native-compiler-pipeline`; this record creates neither.
