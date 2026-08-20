## Context

The maintained fork has three overlapping source-level representations:

1. `asCScriptNode`, a generic token/tree node allocated from Parser `FMemStackBase` and retained by `asCBuilder` only for the current build;
2. transient `asCCompiler`/`asCExprContext` state that combines resolved types, overload/property decisions, temporaries, bytecode, and compiler control-flow state; and
3. optional function-owned `asCTypedSemanticFunction` HIR captured beside bytecode for TypedASTJIT.

The HIR proved that resolved calls, explicit conversions, argument provenance, evaluation order, mutation single-evaluation, cleanup, transfer targets, source provenance, and a verifier are required for source-semantic native generation. It did not make the old Parser tree typed, and Bytecode still does not consume it. The resulting compiler has two source-semantic representations plus Bytecode-specific state in the semantic pass.

The end state is not “no HIR” in the compiler-theory sense. It is one canonical typed AST that assumes the high-level semantic role and eliminates the separately captured sidecar model. The current HIR data layout may disappear; its proven semantics and tests remain requirements.

The primary architecture reference is local `Reference/llvm-project` at commit `9bc4fd0fafb58ff1fb50231e39a882a678542dac`. LLVM core has no source-language AST; the relevant model is Clang's `SourceManager`, Parser calling Sema actions, `ASTContext`, `Decl`/`Type`/`Stmt`/`Expr`, implicit semantic nodes, read-only CodeGen, and on-demand CFG. daScript remains a secondary example of a typed/normalized tree feeding multiple backends.

This change is record-first and long-lived. Its tasks cover the complete migration but implementation proceeds through independently verifiable milestones. No milestone may delete the legacy semantic oracle before its replacement consumer and differential coverage exist.

## Goals / Non-Goals

**Goals:**

- Establish an AngelScript-native frontend structurally equivalent to the useful Clang layers without introducing a Clang build/runtime dependency.
- Make one sealed canonical typed AST the source-level semantic authority for declarations, types, statements, expressions, Bytecode, TypedASTJIT, public inspection, and AST-aware Cache V2 restore.
- Cover every currently accepted AngelScript construct in canonical Sema/AST/Bytecode by the final cutover; error recovery may use explicit invalid/error nodes that never reach executable CodeGen.
- Preserve current language, embedding, VM, UE reflection/routing, Hot Reload, debugger, coverage, timeout, and diagnostics behavior that is covered by the maintained test suite.
- Keep the existing TypedASTJIT native capability surface and per-function fallback behavior while changing only its body input from HIR to canonical AST.
- Provide a versioned public read-only AST snapshot API safe across Hot Reload and asynchronous analysis.
- Preserve function-granular Cache V2 reuse and module-atomic activation while making retained AST reconstructible from stable, pointer-free records.
- Retain Standalone compatibility and keep Unreal types out of the maintained frontend representation.
- Leave a direct future lowering boundary for LLVM IR without implementing or testing an LLVM backend in this change.

**Non-Goals:**

- Linking `clangAST`, `clangSema`, or other Clang libraries; copying/cutting Clang source; or adopting C/C++/Objective-C template/PCH/module complexity.
- Replacing Runtime/VM `asCDataType`, `asCTypeInfo`, GC, object layout, public type IDs, or embedding object semantics wholesale.
- Changing accepted AngelScript syntax or intentional language behavior.
- Requiring new Bytecode to match legacy Bytecode bytes when both satisfy the same observable behavior and versioned persistence contracts.
- Expanding TypedASTJIT to native-emit every AST node, object lifetime, container, delegate, lambda, exception-handler, suspend, Blueprint, RPC, or virtual route.
- Implementing LLVM IR lowering, ORC, object caching, executable memory, deoptimization, or an LLVM production backend.
- Publishing mutable AST nodes, AST rewriting APIs, internal arena pointers, or a stable concrete C++ node class ABI.
- Keeping a permanent production `dual` compiler or shadow-execution mode after canonical cutover.

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

Every executable expression has an exact `asCQualType`, value category, source range, and explicit resolved semantics. Implicit conversions, compiler-generated calls, default/hidden arguments, property rewrites, materialized temporaries, cleanup scopes, and control-transfer targets are AST facts rather than backend inference.

Nodes may be mutable only while Sema owns the unsealed context. Successful module compilation seals and verifies the snapshot. Published, cached, or backend-visible nodes are immutable.

### 4. Sema becomes the only semantic authority

`asCSema` owns:

- declaration registration and scope/namespace lookup;
- canonical type construction and qualifier checks;
- overload, constructor, conversion, operator, property, and mixin resolution;
- argument origins, hidden/default arguments, effective receivers, and ABI-independent call shape;
- reference/handle/value categories and assignability;
- temporary construction, materialization, cleanup, and exceptional cleanup plans;
- global/import/dependency provenance and stable target references;
- loop/switch phases and verified `break`/`continue`/`return` targets;
- diagnostic emission and explicit error/recovery nodes.

`asCExprContext` may remain as a migration adapter but loses `asCByteCode bc` and HIR-sidecar identity before final cutover. No Bytecode or native temporary is stored in Sema or AST.

### 5. QualType is an AST type system with a Runtime bridge

The frontend introduces canonical `asCType` plus compact `asCQualType`. It captures source-semantic identity and qualifiers without embedding `asCTypeInfo*` in public/cache identity.

An explicit `asCRuntimeTypeBridge` resolves canonical type keys to the current Engine's `asCDataType`, `asCTypeInfo`, type ID, layout, behaviours, bindings, and target-profile ABI view. Live CodeGen may use this resolved view while the owning Engine/module is alive. Public snapshots and disk DTOs expose only snapshot-local `asASTTypeRef` plus stable type keys.

Alternative rejected: replace the entire Runtime type system in the same change. That would combine frontend migration with VM/GC/object-layout/public embedding redesign and remove the ability to establish behavior parity incrementally.

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

Cross-module AST references are stable declaration/type keys with an optional Engine-local resolved view held by the current generation. They are not arena pointers into another snapshot. The last lease releases source tables, nodes, stable-reference tables, and resolution views together.

### 8. Cache V2 stores stable AST DTOs, not live objects

Cache V2 continues to use SourceIndex, ModuleInterface, TypeSchema, ModuleState, FunctionBody, DebugSidecar, and atomic ModuleSnapshot assembly. Canonical AST persistence extends those versioned records instead of writing a monolithic memory image:

- source, declaration, type, and global reconstruction data aligns with SourceIndex, ModuleInterface, TypeSchema, and ModuleState;
- a FunctionBody may link an optional `ASTBodySidecar` containing pointer-free function-body nodes and stable references;
- all record links include owner keys, profile/schema versions, content hashes, and canonical absence coordinates;
- live numeric IDs and pointers are assigned only after validation/remap in the target Engine.

Capture-on ExactStartup publishes a module only after every required declaration/type/body AST fragment is present, version-compatible, remapped, sealed, and verified. Missing/corrupt/mismatched fragments are a safe miss before Engine mutation. Capture-off restore ignores AST sidecars and may publish VM-only state.

Incremental compilation may reuse unchanged FunctionBody/ASTBodySidecar pairs after the authoritative frontend re-establishes current declaration/type authority and validates actual dependency inputs. A changed function rebuilds only its body record and required dependency closure; module activation remains atomic.

`SaveByteCode`, VM FunctionBody bytes, public AST dumps, `.hir.txt`, and `.hir.json` are not AST persistence inputs. The unimplemented `TypedHIRSidecar` name/schema is replaced before any record kind is published.

### 9. Bytecode becomes a read-only AST backend

`asCBytecodeCodeGen` consumes sealed declarations and bodies and owns all VM stack slots, temporary registers, labels, patch lists, exception tables, debug position emission, safe points, dependency relocations, and final bytecode buffers. It may query the Runtime type bridge but cannot perform overload selection or insert unrecorded conversions/cleanup.

During migration, legacy and canonical pipelines compile the same fixtures in separate Engines. Acceptance is based on:

- compile success/failure and maintained diagnostics;
- VM observable results and exceptions;
- argument/evaluation order and mutation single-evaluation;
- cleanup/destructor and global/import behavior;
- debugger/coverage/timeout metadata contracts;
- stable dependency and Cache V2 summaries.

Byte-for-byte instruction equality is diagnostic evidence, not a cutover requirement. SaveByteCode/Cache readers use explicit payload/schema versions and reject unsupported content safely.

### 10. TypedASTJIT migrates without widening native eligibility

`FAngelscriptTypedASTJIT` reads the internal sealed AST snapshot and shares no body IR with BytecodeJIT. Current HIR analysis/emission visitors are ported to the equivalent canonical nodes while preserving:

- source/root selection and complete call-closure validation;
- argument order, effective receivers, mutation plans, cleanup, recursion budgets, exception metadata, and semantic dependencies;
- native-call linkage/bridge decisions and Unreal route safety;
- Provider VM/Raw/Parms entry shapes and leases;
- per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback;
- no production `dual` backend.

Forms outside current TypedASTJIT eligibility remain typed AST nodes and still compile to Bytecode; they do not justify a legacy frontend or HIR fallback.

### 11. Primary Generate and native forms are absorbed from the superseded change

Matching-profile Editor Generate reads the current primary Engine's immutable compiled graph and retained AST snapshot after a freshness gate. It does not create a sibling generation Engine, force-clean, compile, reload, reinstance, or mutate primary packages/routes/registries.

Non-matching Editor profiles and isolated commandlets use exactly one contained generation Engine at a time, compile the complete source graph for that profile, retain its canonical AST for generation, emit only the selected module set, and destroy request-owned state afterward.

Native bind replay remains per Engine. A process-global, stable-declaration-keyed native-form recipe catalog records reviewed HeaderInline/module-exported/bridge metadata after real declaration registration, so matching-profile Generate does not need a sibling Engine solely to retain pointer-keyed native forms. Missing/unproven recipes degrade to bridge/fallback.

Generate freezes Hot Reload queue application for the request. Success and every early-fail path preserve primary package, reflection, route, cache, UObject/CDO, delegate, world, and pooled-context ownership except explicitly owned output files.

### 12. Shadow convergence is the migration mechanism, not the final architecture

The same OpenSpec carries the complete migration, but the implementation advances through gates:

1. freeze legacy/HIR/VM/StaticJIT semantic oracles;
2. introduce SourceManager, ASTContext, node/type IDs, verifier, and dump;
3. shadow-build declaration/type AST;
4. shadow-build complete expression/statement/lifetime AST;
5. publish public snapshots and Cache V2 DTOs;
6. move TypedASTJIT to canonical AST;
7. add canonical BytecodeCodeGen and differential execution;
8. make canonical pipeline the default and then the only production path;
9. remove HIR capture/builder, legacy mixed fields, and old `asCScriptNode` production consumers.

No milestone may use partial canonical AST as executable authority. Unsupported shadow capture records diagnostics while legacy compilation remains authoritative. Final cutover requires canonical coverage for every active language/SDK/compiler fixture; only explicitly invalid/error-recovery nodes may remain non-executable.

Alternative rejected: big-bang replacement. It removes the only practical oracle for a 20k+ line mixed compiler and makes language, VM, UE, cache, and StaticJIT regressions inseparable.

Alternative rejected: wrap current HIR as the public AST. It would freeze function-owned sidecar shape, retain duplicate declaration syntax, and preserve Engine-local type/function identity problems.

### 13. LLVM readiness is a boundary constraint only

Canonical AST must contain all language semantics needed for lowering without decoding Bytecode or re-running Sema: exact types/value categories, resolved declarations/calls, explicit conversions, sequencing, temporaries, cleanup, control targets, source locations, and stable dependencies.

Backend state is isolated, and an on-demand typed CFG can be derived later when data-flow optimization requires it. No LLVM type, `llvm::Value*`, LLVM ownership, pass pipeline, object cache, ORC API, or LLVM test appears in this change.

## Risks / Trade-offs

- [One change spans a long migration] -> Keep tasks milestone-grouped, require each gate to be independently buildable/testable, and rewrite later tasks when evidence changes without splitting semantic authority across competing OpenSpecs.
- [Shadow construction doubles compile work and memory] -> Restrict shadow mode to development/test profiles, measure it, and remove it after canonical cutover; do not ship permanent dual compilation.
- [Public API freezes immature details] -> Publish only opaque IDs and size/versioned views, retain V1, and keep concrete node classes private.
- [Retained AST increases Editor memory] -> Make retention module/profile-specific, discard bodies after CodeGen by default, expose counters, and keep Shipping VM-only profiles capture-off.
- [Old snapshots outlive current Engine objects] -> Store stable keys and snapshot-owned data publicly; isolate Engine-local resolved views and release them with generation leases.
- [Cache sidecars diverge from live AST] -> Encode/decode through a separate DTO, deterministic round-trip tests, verifier after remap, content hashes, and miss-before-mutation.
- [New Bytecode changes instruction shape] -> Compare observable execution/metadata in separate Engines, version persisted payloads, and retain legacy path until the complete parity gate passes.
- [Sema extraction changes diagnostics] -> Keep exact diagnostic regression fixtures and source-range tests; intentional changes require explicit spec/test updates rather than incidental churn.
- [TypedASTJIT loses supported forms] -> Port existing HIR semantic tests and generated-output/differential fixtures before removing each HIR visitor.
- [Clang model is copied too literally] -> Use only ownership/layering/implicit-node principles; exclude C++ templates, PCH, macro-generated hierarchy breadth, and unrelated language modes.
- [Primary Generate races Hot Reload] -> Freeze application, acquire immutable inventory/AST leases, freshness-check before output, and queue changes for normal processing afterward.
- [Native-form catalog aliases declarations] -> Key by stable declaration identity plus target/bind profile and validate ABI/linkage/route metadata at lookup.

## Migration Plan

1. Record normalized baseline dumps and differential fixtures for Parser shape, declarations, Sema decisions, HIR, Bytecode behavior, diagnostics, cleanup, dependencies, and TypedASTJIT.
2. Add SourceManager, ASTContext, ID/type model, verifier, deterministic dumper, and shadow-only creation behind an internal development/test pipeline selection.
3. Move declaration/type/namespace/default/import registration into Parser-to-Sema actions while retaining legacy builder results as the comparison authority.
4. Move expression, statement, call, property, argument, temporary, cleanup, and control semantics into sealed AST nodes until all accepted fixtures verify without HIR reconstruction.
5. Add public AST V1, module retention, Hot Reload snapshot publication/leases, and canonical diagnostic dumping.
6. Add Cache V2 stable AST DTOs and round-trip/ExactStartup/incremental tests; keep legacy source compilation authoritative on any miss.
7. Port TypedASTJIT analysis/emission and primary/generation Engine orchestration to canonical AST while retaining BytecodeJIT/VM fallback.
8. Implement read-only BytecodeCodeGen, compare legacy/canonical behavior in isolated Engines, and make canonical the default only after focused and full parity gates pass.
9. Remove legacy Bytecode emission from Sema, HIR capture/builders/accessors, old HIR cache/dump terminology, and every production `asCScriptNode` consumer; preserve parser testing only for the new parser/actions model.
10. Update public/fork/cache/StaticJIT/Standalone documentation, run final source scans and full project validation, then archive this change only when all tasks are actually complete.

Rollback before final deletion selects the last verified legacy compiler path and ignores canonical AST sidecars through normal version/eligibility misses. After final deletion there is no production dual pipeline; rollback is a source-control release rollback paired with the prior Cache/SaveByteCode reader version, never runtime reinterpretation of incompatible payloads.

## Open Questions

No blocking architecture decision remains for recording this change. Implementation evidence may overturn task ordering or internal class names, but changing the public V1 contract, Cache atomicity, behavior-compatibility target, Clang-style phase boundaries, LLVM non-goal, or final removal of duplicate HIR requires an explicit design/spec revision before implementation continues.
