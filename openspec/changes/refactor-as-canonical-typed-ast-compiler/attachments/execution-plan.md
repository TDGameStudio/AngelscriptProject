# Canonical typed AST compiler — execution plan

> **For agentic workers:** implement in `D:\as-cta` (junction to `.worktrees\refactor-as-canonical-typed-ast-compiler`). Dual-repo: plugin submodule first, then parent gitlink + OpenSpec. Use only `Tools\RunBuild.ps1`, `Tools\RunTests.ps1`, `Tools\RunTestSuite.ps1` via `D:\as-cta`. TDD for every `<!-- TDD -->` task.

**Goal:** One Clang-shaped AngelScript frontend (`SourceManager → Parser + Sema → ASTContext`) whose sealed typed AST is the sole source-level authority for Bytecode, TypedASTJIT, Cache V2, public V1, and a future LLVM lowering boundary — without linking LLVM.

**Architecture:** Adopt Clang layering and implicit-node completeness; keep AngelScript handles/imports/UE routes; intern types like Clang QualType; expose only opaque snapshot IDs publicly. Shadow-converge against the current HIR/VM oracles, then cut over and delete sidecar HIR.

**Tech stack:** Maintained fork under `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source`, Native SDK tests under `AngelscriptTest/AngelScriptSDK`, UE Runtime/Editor/StaticJIT/Cache as specified in `tasks.md`. LLVM 22.1.8 at `Reference/llvm-project` is research-only.

**Global constraints:**

- No Unreal types in maintained frontend files (`as_ast_*`, `as_source_manager`, `as_sema*`, `as_bytecode_codegen`).
- No Clang/LLVM link, headers, or `llvm::` types in production.
- No public concrete node ABI; V1 is opaque IDs + size/versioned POD views.
- Language/VM/UE observable behavior stays compatible; bytecode bytes need not match.
- TypedASTJIT eligibility surface does not widen.
- Canonical default stays off until tasks 1–9 pass.
- Build through `D:\as-cta` (`ProjectFile=D:\as-cta\AngelscriptProject.uproject`) because the long worktree path exceeds UBT 260.

See `attachments/llvm-ast-architecture.md` for encodings.

---

## File map

### Create (maintained fork)

| File | Responsibility |
| --- | --- |
| `.../source/as_source_location.h` | `asCSourceLocation` / `asCSourceRange` |
| `.../source/as_source_manager.h/.cpp` | FileID tables, origins, line maps, remap |
| `.../source/as_ast_fwd.h` | Opaque IDs, pipeline enum, isa/cast |
| `.../source/as_ast_kind.h` | Decl/Stmt/Expr/Type/value-category kinds |
| `.../source/as_ast_type.h/.cpp` | interned `asCType`, `asCQualType` |
| `.../source/as_decl.h/.cpp` | declaration nodes |
| `.../source/as_stmt.h/.cpp` | statement nodes |
| `.../source/as_expr.h/.cpp` | expression nodes including implicit/sequence/cleanup |
| `.../source/as_ast_context.h/.cpp` | arena, tables, TU root, seal |
| `.../source/as_ast_verifier.h/.cpp` | pre-seal verification |
| `.../source/as_ast_dump.h/.cpp` | address-free deterministic dump |
| `.../source/as_runtime_type_bridge.h/.cpp` | AST type ↔ Engine `asCDataType` |
| `.../source/as_sema.h/.cpp` | Sema authority |
| `.../source/as_sema_decl.h/.cpp` | declaration Sema actions |
| `.../source/as_sema_expr.h/.cpp` | expression Sema |
| `.../source/as_sema_stmt.h/.cpp` | statement/control Sema |
| `.../source/as_sema_lifetime.h/.cpp` | materialize/cleanup plans |
| `.../source/as_bytecode_codegen.h/.cpp` | read-only VM backend |
| `.../source/as_ast_public_view.h/.cpp` | `asIASTSnapshot` adapter |
| `.../source/as_ast_snapshot_storage.h/.cpp` | module-owned sealed storage + leases |

### Modify (fork / Runtime / Editor)

| File | Change |
| --- | --- |
| `Core/angelscript.h` | `asEASTRetentionPolicy`, opaque IDs, `asIASTSnapshot`, module V1 methods (task 3) |
| `source/as_scriptengine.h/.cpp` | `SetCompilerPipeline`, `ep.canonicalCompilerPipeline` |
| `source/as_module.h/.cpp` | retention policy, snapshot acquire, Build pipeline branch |
| `source/as_parser.cpp` | Sema actions instead of semantic `asCScriptNode` consumers |
| `source/as_builder.cpp` | shadow then replace declaration registration |
| `source/as_compiler.cpp` | strip `asCExprContext::bc` after CodeGen exists |
| `Standalone/CMakeLists.txt` | list every new fork `.cpp` |
| `Cache/AngelscriptCacheTypes.h` + new sidecar files | `ASTBodySidecar` |
| TypedASTJIT visitors | consume sealed AST |
| `AngelscriptProjectSourceGraph` / generator | primary Generate leases AST |
| Docs listed in task 11 | canonical AST / no LLVM backend |

### Tests (create)

Paths are under `Plugins/Angelscript/Source/AngelscriptTest/` unless noted.

- `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalCompilerDifferentialTests.cpp`
- `AngelScriptSDK/Support/AngelscriptNativeCanonicalASTTestSupport.h`
- `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeSourceManagerTests.cpp`
- `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTContextTests.cpp`
- `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTTypeTests.cpp`
- `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp`
- `AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDumpTests.cpp`
- `AngelScriptSDK/Frontend/CanonicalAST/` declaration baseline tests (task 1.3)
- `AngelScriptSDK/Compiler/CanonicalAST/Semantics/` VM matrices (task 1.4)
- `AngelScriptSDK/Module/AngelscriptNativeASTSnapshotAPITests.cpp`
- `HotReload/AngelscriptCanonicalASTSnapshotReloadTests.cpp`
- `Cache/AngelscriptCacheASTBodySidecarTests.cpp`
- `StaticJIT/TypedASTJIT/CanonicalASTMigration/` (task 1.5 / 7.x)
- Standalone CTests (task 11.1)

---

## Section 1 — Freeze semantic and differential baselines

**Interfaces produced:** `FCanonicalASTTestSupport` helpers; `asCScriptEngine::SetCompilerPipeline`; diagnostic token `canonical compiler pipeline is not implemented` until CodeGen is ready.

| Task | Files | Verify |
| --- | --- | --- |
| 1.1 | Create differential tests; modify `as_scriptengine.h/.cpp`, `as_module.cpp` | `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label canonical-ast-differential -TimeoutMs 600000` |
| 1.2 | `AngelscriptNativeCanonicalASTTestSupport.h`; adapt HIR tests in place (do not delete) | Compiler prefix, existing TypedSemanticIR green |
| 1.3 | `Frontend/CanonicalAST/` declaration baselines | Frontend prefix `-Label canonical-ast-frontend-baseline` |
| 1.4 | `Compiler/CanonicalAST/Semantics/` | Compiler prefix, no new skips |
| 1.5 | `StaticJIT/TypedASTJIT/CanonicalASTMigration/` | StaticJIT prefix |
| 1.6 | `attachments/semantic-contract-matrix.md` | file exists; every HIR kind has AST/Bytecode/JIT/Cache/removal columns |

## Section 2 — SourceManager and AST foundation

**Interfaces produced:**

```cpp
enum asECompilerPipeline { asCOMPILER_PIPELINE_LEGACY = 0, asCOMPILER_PIPELINE_CANONICAL = 1 };
class asCSourceManager { asASTFileID AddSection(logicalKey, origin, bytes, lineOffset); asCSourceLocation MakeLocation(file, offset); bool GetLineColumn(...); void RemapLogicalToLocal(...); };
class asCASTContext { asASTDeclId CreateDecl(...); asCQualType InternType(...); int Seal(); bool IsSealed() const; };
int asCASTVerify(const asCASTContext&, asSAstVerifyResult&);
void asCASTDump(const asCASTContext&, asCString& out);
```

| Task | Files | Verify |
| --- | --- | --- |
| 2.1 | SourceManager tests (failing first) | Frontend CanonicalAST prefix, missing-type/link failures then pass |
| 2.2 | `as_source_manager.*`; CMake; diagnostics still use manager coords | same prefix + existing source-range tests |
| 2.3 | Context tests | Frontend prefix |
| 2.4 | `as_ast_fwd.h`, `as_ast_kind.h`, `as_ast_context.*`, `as_decl.*`, `as_stmt.*`, `as_expr.*` | Frontend + Compiler prefixes |
| 2.5 | Type tests | Frontend prefix |
| 2.6 | `as_ast_type.*`, `as_runtime_type_bridge.*` | TypeSystem prefix later; intern tests now |
| 2.7 | Verifier/dump tests | Frontend prefix |
| 2.8 | `as_ast_verifier.*`, `as_ast_dump.*` | `Tools\RunBuild.ps1 -Label canonical-ast-foundation -TimeoutMs 1800000 -NoXGE` then Frontend+Compiler |

## Section 3 — Public AST V1 and Hot Reload leases

**Interfaces produced:** exact V1 block from `design.md` in `Core/angelscript.h`. Module storage `asCASTSnapshotStorage` with AddRef/Release and `IsCurrentGeneration`.

Verify: build `canonical-ast-public-snapshot`, Module prefix, HotReload prefix (task 3.8).

## Section 4 — Declaration/type Sema

**Interfaces produced:** `asCSema` declaration actions; Parser calls them; shadow dump vs `asCBuilder`. Mismatch gate reports deterministic diffs.

Verify: build `canonical-ast-decl-sema`, Frontend, Compiler, Module, TypeSystem prefixes (task 4.7).

## Section 5 — Expression/statement/lifetime Sema

**Interfaces produced:** `as_sema_expr/stmt/lifetime`; implicit conversion, call provenance, sequence, cleanup, control targets as AST facts (Clang ImplicitCast/OpaqueValue/ExprWithCleanups equivalents).

Verify: build `canonical-ast-body-sema` plus Compiler/Language/Runtime/Module/TypeSystem/Embedding/Conformance prefixes (task 5.10). Store summary in `attachments/body-sema-results.md`.

## Section 6 — Cache V2 AST DTO

**Interfaces produced:** `ASTBodySidecar` record kind replacing unimplemented `TypedHIRSidecar`; pointer-free encode/decode; ExactStartup retain vs discard.

Verify: build `canonical-ast-cache-v2`, Cache prefix (task 6.8).

## Section 7 — TypedASTJIT migration

Port HIR visitors to canonical Decl/Stmt/Expr. No `GetByteCode()` for body meaning. No eligibility widening.

Verify: StaticJIT prefix; only then remove production `GetTypedSemanticFunction()` reads (task 7.8).

## Section 8 — Primary Generate / native-form catalog / diagnostics

Absorb superseded change onto retained AST snapshots. Native-form catalog is process-global stable-declaration keyed.

Verify: build `canonical-ast-primary-generate`, StaticJIT, HotReload, Cache (task 8.9).

## Section 9 — Canonical Bytecode CodeGen

Read-only backend. Isolated-engine differential vs legacy. Canonical remains opt-in until 9.9 passes.

Verify: build `canonical-ast-bytecode`, all AngelScriptSDK prefixes (task 9.9).

## Section 10 — Canonical cutover, HIR removal, and LEGACY isolation

Default CANONICAL only after sections 1–9. Then physically delete the added
TypedSemantic HIR capture/builder/storage/accessor/consumer surface and remove
every CANONICAL semantic dependency on `asCScriptNode` or `asCExprContext`.
Retain AngelScript's native `asCScriptNode` syntax/recovery tree,
`asCBuilder`, `asCCompiler`, Parser coverage, and explicit LEGACY selection as
an independent reference/compatibility/rollback path. Reject `dual`, fact
merging, semantic replay, and silent CANONICAL-to-LEGACY fallback. Run the
forbidden-symbol scan against HIR and CANONICAL dependency boundaries; it must
not treat retained native LEGACY files as forbidden merely because they contain
native AST/compiler symbols.

Verify: build `canonical-ast-cutover` (task 10.9). Do not mark complete if any active fixture still needs removed paths.

## Section 11 — Standalone, public API, docs

CMake + CTests; no UE/Clang/LLVM link. Update fork/cache/StaticJIT/Standalone guides and ZH knowledge articles. Public migration notes. Dump stays observer-only.

Verify: `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-ast-standalone -TimeoutMs 600000`.

## Section 12 — Final verification

Build `canonical-ast-final`; focused prefixes; Standalone Debug+Release; `All` suite; `openspec validate`; ABI/source scans. Archive only when the user requests closure.

---

## Milestone order (do not skip)

1. Foundation (2) + pipeline flag (1.1) so later work has types.
2. Baselines (1.2–1.6) against live HIR/VM.
3. Public V1 + leases (3) can proceed in parallel with decl Sema (4) after context exists.
4. Body Sema (5) after decl Sema.
5. Cache (6) and TypedASTJIT (7) after sealed complete AST.
6. Generate (8) after retain snapshots.
7. Bytecode CodeGen (9) after body Sema.
8. Cutover (10) only with parity evidence.
9. Docs + final gates (11–12).

## LLVM readiness (non-goal, boundary)

Every executable expr must have exact QualType, value category, resolved target, explicit conversion/sequence/cleanup, and source range so a future LLVM builder can walk the sealed AST without Bytecode decode or second Sema. No LLVM types in this change.
