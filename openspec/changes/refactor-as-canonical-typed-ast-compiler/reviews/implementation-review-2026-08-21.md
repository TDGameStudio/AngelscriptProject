# Canonical Typed AST Compiler Implementation Review — 2026-08-21

## Review decision

The current implementation is **Request changes**.

It is not accepted as a completed production cutover, must not be archived as complete, and is not yet a safe source-semantic contract for a production LLVM backend.

The implementation has built a useful migration platform that should be preserved:

- standard-C++ AST nodes and `asCASTContext`;
- `asCSourceManager` and source ranges;
- Parser-to-Sema attachment;
- AST verifier and deterministic dump;
- public snapshot and retention-policy prototypes;
- an isolated sealed-AST Bytecode CodeGen prototype;
- Cache record-kind and sidecar prototypes;
- canonical TypedASTJIT visitors;
- StaticJIT generation integration;
- differential and integration test scaffolding.

However, the production compiler authority, exact semantic graph, stable identity, public ABI, snapshot concurrency, Cache reconstruction, and verifier guarantees required by this change are not implemented. The current system is best described as:

```text
legacy Parser/asCScriptNode
    + legacy Builder/asCCompiler production Bytecode
    + canonical AST shadow capture
    + subset consumer prototypes
```

It is not yet:

```text
SourceManager
    -> Parser + authoritative Sema
    -> sealed canonical typed AST
    -> canonical Bytecode / TypedASTJIT / future LLVM
```

## Scope and reproducible evidence

Reviewed worktree:

- path: `D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`;
- short junction used by existing verification: `D:\as-cta`;
- branch: `refactor-as-canonical-typed-ast-compiler`;
- plugin submodule: `Plugins/Angelscript`.

Review inputs:

- `proposal.md`, `design.md`, `tasks.md`, and all capability specs in this change;
- milestone and verification attachments;
- maintained-fork Parser, Builder, Compiler, Sema, AST, SourceManager, verifier, sidecar, module, and CodeGen sources;
- UE Cache, StaticJIT, TypedASTJIT, Hot Reload, and public snapshot integration;
- new canonical AST, Cache, Module, StaticJIT, and cutover tests;
- current Git and test-run state.

Fresh record checks performed during review:

```powershell
openspec validate refactor-as-canonical-typed-ast-compiler
git diff --check
git -C Plugins/Angelscript diff --check
openspec instructions apply --change refactor-as-canonical-typed-ast-compiler --json
```

Observed target-worktree task state at review time:

- total: `93`;
- checked: `90`;
- unchecked: `3` (`12.2`, `12.4`, `12.6`).

The `90/93` count is only the state of the rewritten checklist. It is not evidence that 96.8% of the normative capability requirements are implemented.

## Normative record divergence

The change record currently contradicts itself.

The capability specs require:

- the canonical AST to be the sole source-level semantic authority;
- Sema to be the only authority for lookup, overloads, conversions, calls, arguments, lifetimes, cleanup, imports, globals, dependencies, and control targets;
- production Bytecode CodeGen to consume only sealed canonical AST;
- TypedASTJIT to consume the canonical AST through an immutable snapshot lease;
- Cache V2 to reconstruct one complete verified module AST;
- final cutover to remove production HIR, legacy compiler selection, and semantic dependence on `asCScriptNode`.

Relevant normative locations:

- `specs/as-canonical-typed-ast/spec.md:4-28`;
- `specs/as-canonical-typed-ast/spec.md:57-110`;
- `specs/as-canonical-compiler-pipeline/spec.md:4-17`;
- `specs/as-canonical-compiler-pipeline/spec.md:41-59`;
- `specs/as-incremental-script-cache/spec.md:3-34`;
- `specs/as-typed-ast-jit-backend/spec.md:4-29`.

The rewritten task section instead states that:

- `asCCompiler` continues to emit production Bytecode;
- `asCScriptNode` continues to feed Sema;
- HIR types remain as TypedASTJIT/test oracles;
- canonical Bytecode CodeGen remains a subset backend.

Relevant task and attachment locations:

- `tasks.md:105-117`;
- `attachments/cutover-results.md:31-37`;
- `attachments/milestone-progress.md:22-25`.

Changing `tasks.md` is allowed as implementation evidence changes, but the proposal, design, specs, tasks, milestone claims, and product documentation must be reconciled together. Rewriting only the tasks does not satisfy or retire the opposite normative requirements.

## Scorecard

| Area | Current evidence | Review decision |
| --- | --- | --- |
| Standard-C++ AST scaffold | Implemented | Preserve |
| Parser→Sema attachment | Implemented as post-parse `asCScriptNode` walk | Shadow only |
| Sema semantic authority | Not implemented | Blocking |
| Canonical production Bytecode | No production `asCBytecodeCodeGen::Generate` call | Blocking |
| Exact stable declaration identity | Name-only keys and binding | Blocking |
| Public AST ABI | Vtable insertion and unsafe view negotiation | Blocking |
| Snapshot publication/Acquire | Raw-pointer race and non-atomic replacement | Blocking |
| Cache V2 AST restore | Placeholder envelope; no body reconstruction | Blocking |
| Arena ownership | Per-node `asNEW`/`asDELETE` | High |
| Sealed immutability | Mutable node/context/source access remains | High |
| Verifier completeness | Table sanity subset only | High |
| CodeGen failure atomicity | Funcdef/global mutation can survive failure | High |
| Unified SourceManager truth | Not used by legacy diagnostics; incomplete provenance | High |
| OpenSpec schema validation | Pass | Record structure only |
| Parent/plugin `git diff --check` | Pass | Whitespace only |
| Focused regression evidence | Multiple prefixes reported green | Compatibility evidence only |
| Final All suite | In progress at review capture | Not complete |

## R01 — Blocking: canonical production selection does not select canonical Bytecode

### Evidence

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp:787` defaults `canonicalCompilerPipeline` to true.
- `.../as_scriptengine.h:232-251` maps the bool to `CANONICAL` and makes `IsCanonicalBytecodeCodeGenReady()` return true unconditionally.
- `.../as_module.cpp:393-406` calls `builder->BuildCompileCode()` in the production `Build()` path.
- `.../as_builder.cpp:863-896` and `1508-1644` instantiate `asCCompiler` for factories, functions, constructors, destructors, and generated bodies.
- `.../as_builder.cpp:1015-1141` uses `asCCompiler` for public `CompileFunction()`.
- `.../as_bytecode_codegen.cpp:1362` defines `asCBytecodeCodeGen::Generate()`, but source scanning found no production caller; callers are isolated tests.
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTCutoverTests.cpp:23-158` verifies a selection flag plus successful execution, not the backend that produced the Bytecode.
- The same test file at `252-274` explicitly preserves value-object execution through the internal legacy compiler under the canonical flag.

### Impact

The current selection can report canonical production readiness while every executable result still comes from the legacy compiler. Tests, diagnostics, Cache decisions, StaticJIT generation, and future LLVM work can therefore attribute legacy semantics to the new pipeline incorrectly.

### Required correction

Until canonical CodeGen is the real production backend:

- keep production selection `LEGACY`; or
- rename the state to explicit shadow/capture terminology such as `CANONICAL_CAPTURE`;
- remove the unconditional ready result;
- make backend provenance observable in cutover tests.

### Rereview gate

A cutover test must fail if `asCCompiler` is invoked for the selected canonical Engine and must prove that executable Bytecode was published by `asCBytecodeCodeGen` from the same sealed AST snapshot.

## R02 — Blocking: current Sema is a syntax conversion pass, not the semantic authority

### Evidence

- `.../as_parser.cpp:2321-2335` builds a complete `asCScriptNode` tree before invoking `ActOnParsedScript()`.
- `.../as_sema_decl.cpp` includes and recursively walks `as_scriptnode.h`.
- `.../as_sema.cpp:6-11` stores but does not use the Engine.
- `.../as_sema_expr.cpp:29-49` resolves names by returning the first same-name child found while walking parent scopes.
- `.../as_sema_expr.cpp:63-170` defaults expression types to `int`; string and other non-bool/non-int constants are represented with the `int` type, and null is represented as an integer primitive with a handle qualifier.
- Call arguments are copied into a reversed array at `136-153`, but that array is discarded and the original argument array is stored.
- `.../as_sema_decl.cpp:201-238` classifies the first identifier of a named type as a value object by default and a reference object when a handle qualifier is present.
- `.../as_runtime_type_bridge.cpp:95-115` cannot convert any named `asCDataType` into a canonical type.

### Impact

The AST does not contain exact overload selection, type identity, implicit conversions, access results, property/mixin rewrites, effective receivers, argument provenance, lifetime/cleanup, imports/globals, dependencies, or ABI routes. Bytecode, TypedASTJIT, or LLVM cannot safely treat it as final semantic truth.

### Required correction

Move real language decisions out of `asCCompiler` into a semantic environment with explicit scopes, symbols, overload candidates, canonical types, conversions, call plans, lifetime plans, and control targets. Parser nodes may remain recovery input during migration, but the sealed graph must contain all decisions needed by every backend.

### Rereview gate

Representative overload, constructor, conversion, property, mixin, named/default argument, receiver, cleanup, global/import, template, delegate, lambda, and control-transfer fixtures must be expressed exactly in the AST and consumed without rerunning legacy semantic analysis.

## R03 — Blocking: stable declaration keys and StaticJIT AST binding collide for overloads

### Evidence

- `.../as_sema.cpp:13-32` builds each stable key as `parent stable key + "::" + declaration name`.
- The key omits declaration kind, complete namespace identity, parameter types, return type, method qualifiers, overload identity, module, and profile.
- `.../as_ast_sidecar.cpp:271-303` uses this key as per-function sidecar identity.
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp:1139-1157` binds a Runtime function to the first AST function/method declaration with the same name.

### Impact

Overload B can be associated with overload A's AST body while retaining B's Runtime FunctionKey and ABI. This can produce incorrect native code rather than merely inaccurate diagnostics.

### Required correction

Define one canonical declaration/function identity based on complete stable signature and owner identity. Runtime FunctionKey↔AST declaration mapping must be exact and validated, never name-first.

### Rereview gate

Add explicit global/method/constructor/operator/mixin/namespace overload tests and multiple-lambda tests. Generation must reject any ambiguous or signature-mismatched mapping.

## R04 — Blocking: Cache V2 ASTBodySidecar is a placeholder and discards its input payload

### Evidence

- `.../as_ast_sidecar.cpp:62-113` encodes a textual dump and declaration table only.
- SourceManager tables, canonical types, Stmt/Expr nodes, function bodies, children, resolved references, cleanup plans, and provenance are absent.
- `.../as_ast_sidecar.cpp:116-224` reads but ignores the dump, rebuilds declarations only, classifies every named type as `VALUE_OBJECT`, and falls back to `int`.
- The decoder does not require complete byte consumption and does not implement complete node/type/reference validation.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/AngelscriptCacheASTBodySidecar.cpp:39-72` checks that `CanonicalAstBytes` is non-empty, then ignores all of its contents and encodes a new TranslationUnit-only Context.
- The decode wrapper at `75-101` returns the envelope bytes as `CanonicalAstBytes`, not the caller's original canonical payload.
- Production search found record-kind/archive/diagnostic integration and tests, but no real FunctionBody link or ExactStartup module AST reconstruction.
- `Plugins/Angelscript/Source/AngelscriptTest/Cache/AngelscriptCacheASTBodySidecarTests.cpp:118-136` uses `{1}` as the input AST bytes and does not assert payload fidelity.

### Impact

The current sidecar cannot restore function semantics, cannot reconstruct a complete module AST, and cannot provide a zero-frontend retain-policy ExactStartup path. Documentation that states otherwise is premature.

### Required correction

Implement versioned pointer-free per-function DTOs containing complete source/type/decl/body/reference/dependency information. Rebuild a detached target-Engine graph, remap stable identities, seal and verify it, then publish atomically with the restored module.

### Rereview gate

Byte-exact round trip, cross-Engine remap, corruption/mismatch rejection, complete module reconstruction, zero Parser/Sema ExactStartup, and payload-fidelity tests must pass through the real Cache V2 FunctionBody link.

## R05 — Blocking: public AST V1 breaks existing module ABI and does not implement safe view negotiation

### Evidence

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h:1045-1063` inserts three virtual methods into the middle of the existing `asIScriptModule` vtable.
- All following vtable slots move for previously compiled embedding clients.
- `Angelscript.uplugin` remains product version `1.0.0` / numeric version `10000`; no alternative binary-compatibility negotiation accompanies the vtable change.
- `Core/angelscript.h:986-1025` gives each public view `structSize` and `apiVersion` fields.
- `.../as_ast_public_view.cpp:64-142` never reads the caller's size/version and always writes the complete current structure.
- An older caller with a smaller structure can therefore be overwritten.
- `AngelscriptNativeASTSnapshotAPITests.cpp:32-57` passes a zero-initialized view and expects the implementation to overwrite its version, masking caller-size negotiation.
- Current V1 views do not expose source ranges, child/operand traversal, value category, resolved declarations/calls, statement owners/targets, or stable dependencies.
- Public IDs contain only a 1-based integer; an ID from snapshot A can address the same numeric index in snapshot B instead of failing closed.

### Impact

The change can break existing binary embedding clients while simultaneously freezing an API that is too incomplete for real AST consumers and unsafe for future structure growth.

### Required correction

Choose an explicit compatible extension strategy, such as a versioned capability/query interface or a new module extension interface. Callers must initialize size/version, implementations must bound writes by caller size and reject incompatible versions, and V1 must not freeze until traversal requirements are known.

### Rereview gate

Provide old-client ABI evidence, smaller-view canary tests, incompatible-version rejection, foreign-snapshot ID behavior, and complete read-only traversal tests.

## R06 — Blocking: snapshot publication and acquisition are not atomic or thread-safe

### Evidence

- `.../as_module.cpp:1997-2008` reads a raw `astSnapshot` pointer and only then calls `AddRef()` without a lock or atomic retained-pointer protocol.
- A publisher may Release/delete the object between those operations.
- `.../as_ast_public_view.h:27-36` stores `currentGeneration` in a plain `bool`; asynchronous readers and Hot Reload writers form a C++ data race.
- `.../as_module.cpp:2044-2052` invalidates and releases the previous snapshot before sealing and allocating the replacement.
- Replacement verification or allocation failure therefore loses the last successful snapshot.
- `.../as_module.cpp:2076-2084` fabricates a TranslationUnit-only snapshot when the retained build has no canonical Context.
- `.../as_builder.cpp:652-672` silently continues after canonical Context/Sema allocation failure.
- Public `CompileFunction(asCOMP_ADD_TO_MODULE)` creates a local canonical Context but never adopts, merges, or publishes it; the module gains an executable function while the old snapshot remains current and incomplete.
- `AngelscriptNativeCanonicalASTCutoverTests.cpp:213-249` locks the unchanged generation key as expected behavior without checking module/snapshot completeness.
- `FAngelscriptStaticJITGenerationFunction` stores a raw `const asCASTContext* SealedAST`; generation construction does not acquire an `asIASTSnapshot` lease.

### Impact

Concurrent Acquire/replace can use freed memory, `IsCurrentGeneration()` has undefined behavior under concurrent access, failed replacement can destroy valid state, and generation consumers can outlive their AST owner.

### Required correction

Construct and verify the new snapshot fully before publication; exchange it atomically under one synchronization protocol; make Acquire obtain a retained reference in the same protocol; make current-generation state atomic; and require every async/generation consumer to hold an explicit snapshot lease.

### Rereview gate

Add deterministic concurrency tests for Acquire-vs-publish, reader-vs-current-flag update, failed replacement, module discard, CompileFunction completeness, and generation-engine destruction.

## R07 — High: arena ownership and sealed immutability are not implemented

### Evidence

- `design.md:64-82` explicitly forbids individually heap-owned nodes and requires ASTContext arena/batch lifetime.
- `.../as_ast_context.cpp:17-40` individually deletes Decl/Stmt/Expr/Type objects.
- `.../as_ast_context.cpp:62-172` individually allocates each object with `asNEW`.
- `.../as_ast_context.h:18-35` exposes mutable SourceManager and mutable node accessors.
- `DestroyAll()` is public and resets `sealed` to false.
- `.../as_ast_public_view.h:27-29` exposes a mutable Context from the concrete snapshot.
- Sealing blocks creation APIs but does not prevent direct field, child, type, range, target, or source-table mutation.
- `AngelscriptNativeCanonicalASTContextTests.cpp:18-46` names an arena test but checks only allocation, ownership in an empty second Context, sealing, and destruction.

### Required correction

Use a real arena/slab/bump allocator, separate construction APIs from sealed read-only traversal, remove mutable access from backend/snapshot surfaces, and make batch destruction an owner-only operation.

## R08 — High: the verifier is not a semantic graph firewall

### Evidence

`.../as_ast_verifier.cpp:13-188` does not fully verify:

- Stmt/Expr IDs against their table indices;
- expression operands and child kinds;
- parent/child and owner/body bidirectional consistency;
- graph cycles and multiple ownership;
- ancestor and nearest-control-target rules;
- return/fallthrough/switch ordering and ownership;
- mandatory exact expression types/value categories;
- resolved declaration kind/signature compatibility;
- cleanup/materialization/live-value plans;
- stable cross-module references;
- sealed immutable publication invariants.

`.../as_ast_type.cpp:5-12` validates only the encoded direction mask and does not reject unknown bits, direction-without-reference, auto-handle-without-handle, or illegal void qualifiers.

### Required correction

Expand verification to cover every invariant relied upon by Bytecode, TypedASTJIT, Cache, public readers, and future LLVM lowering. Sealed publication must fail before any consumer sees an incomplete graph.

## R09 — High: isolated Bytecode CodeGen can leave partial module state after failure

### Evidence

- `.../as_bytecode_codegen.cpp:1403-1410` calls `module->AddFuncDef()` before full emission succeeds.
- `.../as_bytecode_codegen.cpp:1412-1434` calls `module->AllocateGlobalProperty()` before full emission succeeds.
- Later signature/emitter `asNOT_SUPPORTED` or OOM paths discard pending functions only; funcdef/global changes are not rolled back.

### Impact

This violates Task 9.1's explicit no-partial-module-state requirement and makes retries or fallback against the same module unsafe.

### Required correction

Emit a detached artifact or use a complete transaction that can roll back every type, funcdef, global, function, dependency, and metadata mutation.

## R10 — High: SourceManager is not yet the unified source-coordinate authority

### Evidence

- Current Parser/Builder/legacy Compiler diagnostics do not route through `asCSourceManager`; usage is concentrated in the new AST/Sema/CodeGen files.
- Section state has origin metadata but no authored→processed→generated mapping/provenance graph.
- `.../as_source_manager.cpp:192-204` reuses an existing FileID by logical key and origin without comparing bytes, byte count, or line offset.
- Changed content can therefore reuse stale source bytes and line tables.
- Public views and Cache sidecars do not preserve the complete source-coordinate model.

### Required correction

Make one SourceManager the source truth for Lexer/Parser/Sema/diagnostics/backend metadata, add explicit provenance mapping, and make remap validate content identity or create a new snapshot-local file entry.

## Test and evidence audit

The new test surface is useful, but several tests validate labels or compatibility rather than the required architecture:

- cutover execution succeeds through legacy `asCCompiler` while the test reports canonical selection;
- public snapshot tests traverse only the TranslationUnit and do not prove function/body/range/type completeness;
- public view tests do not cover old/smaller caller buffers;
- foreign-ID tests use an empty second Context, so same-index foreign IDs are not exercised;
- the arena test does not inspect allocation strategy;
- Cache tests do not verify `CanonicalAstBytes` fidelity;
- CompileFunction tests preserve a stale/incomplete snapshot as current;
- Hot Reload tests acquire generation A before replacement and do not race Acquire with publication;
- no test prevents name-only overload-to-AST misbinding.

Reported passing prefixes remain valuable regression evidence. They prove that the legacy-compatible runtime continues to work. They do not prove that the new AST has become the production semantic and Bytecode authority.

The final All suite may finish with zero failures and this review decision would remain unchanged until the source-level blocking findings are corrected.

## What should be preserved

The rework should retain these directions:

1. Keep AST, SourceManager, Sema, verifier, and CodeGen standard C++ without UE, Clang, or LLVM dependencies.
2. Keep internal concrete nodes separate from public opaque snapshots/views.
3. Keep module retention policy and reference-counted generation leases as the public model, after concurrency is corrected.
4. Keep one sealed semantic graph as the long-term input to Bytecode, TypedASTJIT, and future LLVM.
5. Keep differential behavior/diagnostic testing in isolated Engines.
6. Keep Cache persistence pointer-free and stable-key based; do not persist live nodes or dumps.
7. Keep provider bindings free of AST pointers after generation.
8. Keep legacy Bytecode/VM as the semantic oracle and per-function fallback until real parity is demonstrated.

## Required rework order

1. Reconcile `proposal.md`, `design.md`, specs, tasks, attachments, and product documentation. Either restore the original complete-cutover requirements and reopen unsupported tasks, or redefine this change as a phase-1 shadow/scaffold change and record a separate production-cutover change.
2. Correct pipeline naming and readiness reporting so legacy Bytecode is not reported as canonical CodeGen output.
3. Implement the authoritative semantic environment and exact canonical types/calls/lifetimes/control facts.
4. Define complete stable declaration/function signatures and exact Runtime FunctionKey↔AST declaration mapping.
5. Implement actual arena ownership, sealed const traversal, and a complete verifier.
6. Make canonical Bytecode CodeGen produce a detached artifact and install it atomically after full success.
7. Redesign the public module extension ABI and real size/version negotiation before freezing V1.
8. Make snapshot publication, acquisition, current-state reporting, CompileFunction behavior, and generation consumption lease-safe.
9. Implement real FunctionBody-linked Cache V2 AST DTOs and complete verified ExactStartup reconstruction.
10. Add adversarial tests, then rerun focused prefixes, the target UE support matrix, Standalone Debug/Release, and the All suite.

## Minimum rereview matrix

The next implementation review should include fresh evidence for:

- canonical selected Engine invokes no legacy `asCCompiler` production path;
- complete-language source corpus is represented and executed from sealed AST;
- overload/constructor/operator/mixin/lambda identities are unambiguous;
- exact call/argument/receiver/conversion/lifetime facts are visible in AST dumps/views;
- same-index foreign IDs fail safely;
- old/smaller public view buffers are not overwritten;
- concurrent Acquire/publication is race-free;
- failed publication keeps the previous successful generation current;
- CompileFunction has a documented and tested complete-snapshot policy;
- CodeGen failure leaves no type/funcdef/global/function/module mutation;
- sidecar round trip preserves complete function-body payload and stable identities;
- ExactStartup reconstructs one complete verified module AST without Parser/Sema;
- source remap cannot reuse stale bytes/line offsets;
- target UE version or versions are explicitly identified and tested.

## Verification status at review capture

- `openspec validate refactor-as-canonical-typed-ast-compiler`: pass;
- parent `git diff --check`: pass;
- plugin `git diff --check`: pass;
- focused evidence recorded by the change: Compiler `203/203`, Cache `556/556`, Hot Reload `127/127`, StaticJIT `431/431`;
- Standalone evidence recorded by the change: Debug `21/21`, Release `21/21`;
- final task state: `90/93` checked;
- final All suite: still running at review capture, in the Cache prefix;
- actual configured UE executable: UE 5.8;
- repository architecture guidance still describes the product as a UE 5.7 plugin, so supported-version intent requires reconciliation.

This review did not modify plugin source, tests, task checkboxes, proposal, design, or capability specs. It records the implementation findings needed for correction and later rereview.
