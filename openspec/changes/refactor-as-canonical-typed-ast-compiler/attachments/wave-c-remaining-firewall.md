# Wave C remaining firewall inventory

**Date:** 2026-08-21 (inventory); **superseded for implementation by** `wave-c-28-verifier-remainder.md` and `async-work.md`.  
**Worktree:** `D:\as-cta`  
**Change:** `refactor-as-canonical-typed-ast-compiler`  
**Tasks:** **2.4 / 13.4 closed** (construction APIs + const-only public `Get*`). **2.8 / 13.5 still `[ ]`**.  
**Reviews:** R07, R08 (`reviews/implementation-review-2026-08-21.md`)

> This inventory predates construction APIs. Sections that claim missing `AddDeclChild` / public mutable `Get*` / 2.4 still open are **stale**. Use it only as historical scoring of the first verifier slice. Implement the remainder from `wave-c-28-verifier-remainder.md`.

This file inventories **current** fork/test code.  
`attachments/wave-c-g-file-map.md` Wave C section is **stale** (still describes public `DestroyAll` and per-node `asNEW`). Prefer this document + the cited sources.

Wave C **started** here: Context `wave-c-context2` 2/2, Verifier `wave-c-verifier` 3/3, BodySema `wave-c-body-sema` 3/3 after reverting CALL-without-callee.

**2026-08-21 inventory TDD landed** (`attachments/wave-c-results.md`): first verifier slice 8/8, then construction Frontend 58/58. **2.4 / 13.4 are closed.** Do **not** mark 2.8 / 13.5 until `wave-c-28-verifier-remainder.md` close criteria hold.

Fork root: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`  
SDK tests: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/`

---

## 1. Already landed (do not redo)

### Arena / slab / placement-new

- `asCASTContext` owns an inline bump arena (`asSArenaBlock` slabs). Default slab size is **65536** bytes (`as_ast_context.cpp` `Allocate`, ~L43–45).
- Nodes are **placement-new** into arena memory, not per-node `asNEW`:
  - `CreateDecl` ~L147–152
  - `CreateStmt` ~L181–186
  - `CreateExpr` ~L201–206
  - `InternType` ~L239–244
- Batch teardown frees slabs with `asDELETEARRAY` after explicit destructor calls on live nodes (`DestroyAll` ~L85–115). Inspection helpers: `ArenaContains` ~L62–78, `GetArenaUsedBytes` ~L80–83.
- Slab backing still uses `asNEWARRAY(char, cap)` (~L45). That is arena storage, **not** per-node heap ownership.

### Private `DestroyAll` (no public reseal API)

- Declared **private** in `as_ast_context.h` ~L54–55.
- Only called from `~asCASTContext()` (`as_ast_context.cpp` ~L14–16).
- Implementation still clears tables and sets `sealed = false` (~L114), but that path is destructor-only; nothing outside the class can reseal via `DestroyAll`.

### Sealed non-const `Get*` return null

After `Seal()`, mutable accessors refuse the graph:

- `GetDecl` non-const ~L285–291 (`if( sealed || …) return 0`)
- `GetStmt` non-const ~L303–309
- `GetExpr` non-const ~L321–327

Const overloads still traverse (~L294–337). Covered by `ArenaOwnershipSealAndForeignIds` in `AngelscriptNativeCanonicalASTContextTests.cpp` ~L41–44.

### Verifier: stmt table-index mismatch

- `asCASTVerify` rejects `stmt->id != id` with `asAST_VERIFY_FOREIGN_ID` / detail `"stmt-id"` (`as_ast_verifier.cpp` ~L68–70).
- Decl id mismatch already covered (`"decl-id"` ~L31–33).
- Test: `RejectsStmtIndexMismatch` in `AngelscriptNativeCanonicalASTVerifierTests.cpp` ~L55–65.

### Seal still gates on verify

- `asCASTContext::Seal` (~L363–378) calls `asCASTVerify` before setting `sealed = true`. Keep this hook; extend the verifier body.

### Hard no already proven by revert

Requiring CALL/CONSTRUCT `resolvedDecl` as a seal firewall was tried and **reverted**. BodySema/CodeGen graphs still create calls without callees and must seal. Do **not** re-add that check (see §5).

---

## 2. Still missing for 13.4 / 2.4 (R07 seal / immutability)

| Hole | Current evidence | Needed |
| --- | --- | --- |
| Mutable Context on snapshot | `asCASTSnapshot::GetContext()` non-const returns `asCASTContext*` (`as_ast_public_view.h` ~L28). Const overload exists (~L29). `asCModule::GetCanonicalASTContext` is already `const asCASTContext*` (`as_module.cpp` ~L2047–2053) but HotReload tests still call snapshot `GetContext()` as a mutable surface (`AngelscriptCanonicalASTSnapshotReloadTests.cpp` ~L157, L380). | Only `const asCASTContext* GetContext() const`. |
| Non-const `SourceManager` | `asCSourceManager& GetSourceManager()` remains public (`as_ast_context.h` ~L18) with no seal gate. | Construction-only / builder-only; sealed/snapshot path uses const. |
| Non-const node accessors still public | Non-const `GetDecl`/`GetStmt`/`GetExpr` remain on the public class (`as_ast_context.h` ~L29–34). They null out after seal, but unsealed callers (and any pre-seal retained pointer) still get writable `asCDecl*` / `asCStmt*` / `asCExpr*`. R07 wants construction APIs separated and non-const accessors deleted or private (`asCSema` friend / unsealed builder). | Friend/builder handle; backends see const only. |
| Public field mutation on nodes | `as_decl.h`, `as_stmt.h`, `as_expr.h` expose all fields as public POD (intentional for placement-new). Verifier tests still mutate via `Fn->children.PushLast(...)` / `Broken->kind = …` (`AngelscriptNativeCanonicalASTVerifierTests.cpp` ~L28–37). No `AddDeclChild` / `SetBody` / `SetTarget` construction APIs yet (still absent from `as_ast_context.*`). | Unsealed mutation only through context construction APIs; tests stop writing fields through raw pointers once those APIs exist. |
| Per-node `asNEW` | **Gone** for Decl/Stmt/Expr/Type. Do not reintroduce. Optional extract to `as_ast_arena.*` is still open cosmetic/split work; not required to claim arena ownership if slab stays inside `asCASTContext`. | Keep placement-new + batch free. |
| Tests assuming public `DestroyAll` / reseal | **Mostly fixed.** `BulkDestructionClearsTables` no longer calls `DestroyAll` (`AngelscriptNativeCanonicalASTContextTests.cpp` ~L47–56); it only asserts arena ownership/bytes before scope destruction. `ArenaOwnershipSealAndForeignIds` already checks slab containment + post-seal const traversal (~L18–45). Stale file-map claims about these tests are wrong. | Optionally rename `BulkDestructionClearsTables` / add destructor-batch assertion; do not resurrect public `DestroyAll`. |
| tasks.md stale “why open” text for 2.4 | Still claims per-node `asNEW`/`asDELETE` and public `DestroyAll`. That prose lags the tree; holes above are the real remainder. | Update when closing the task; do not re-implement arena. |

**13.4 / 2.4 close criteria (remaining):** snapshot/backend surfaces expose no mutable `asCASTContext*`; sealed path has no writable SourceManager/node accessors; construction stays on unsealed context (friend/builder OK); no public reseal.

---

## 3. Still missing for 13.5 / 2.8 (R08 vs current `asCASTVerify`)

R08 bullets from `reviews/implementation-review-2026-08-21.md` (~L309–321), scored against `as_ast_verifier.cpp` `asCASTVerify` (~L13–193) and `asASTQualifiersAreValid` (`as_ast_type.cpp` ~L5–12).

| R08 bullet | Status | Current coverage / gap |
| --- | --- | --- |
| Stmt/Expr IDs against table indices | **Partial** | Stmt: covered (`"stmt-id"` ~L68–70). Decl: covered (`"decl-id"` ~L31–33). **Expr: absent** — expr loop (~L162–190) never checks `expr->id != id`. |
| Expression operands and child kinds | **Absent** | No walk of `asCExpr::children`; no operand-kind rules for Call/Binary/etc. |
| Parent/child and owner/body bidirectional consistency | **Absent** / coarse one-way only | Decl children must resolve (~L47–52); parent must resolve (~L39–41); body stmt must resolve (~L54–56); stmt owner decl must resolve (~L76–78). Does **not** require `child->parent == parent`, `body` stmt `owner` matching the decl, or reverse child membership. |
| Graph cycles and multiple ownership | **Absent** | No cycle detection; no “two parents / two owners” check. |
| Ancestor and nearest-control-target rules | **Partial** | Break/continue require target kind loop/switch when target set (~L99–117). No ancestor-of-break check; no “skipped nearer loop” rule; missing target is still allowed (`if( stmt->target.IsValid() )`). |
| Return / fallthrough / switch ordering and ownership | **Partial** | Duplicate default/case (~L120–151); fallthrough requires some owner (~L153–158). No fallthrough-inside-switch ordering; no return-target completeness. |
| Mandatory exact expression types / value categories | **Partial** / weak | If `expr->type` is set, type ref must resolve and quals pass `asASTQualifiersAreValid` (~L174–180). **Missing type is allowed.** `valueCategory` never checked. |
| Resolved declaration kind / signature compatibility | **Partial** / weak + **hard no** | If `resolvedDecl` is set, decl must exist (~L182–184). No kind/signature match. **Must not** require CALL/CONSTRUCT `resolvedDecl` (see §5). Later waves may check kind/signature **when** a callee is present. |
| Cleanup / materialization / live-value plans | **Absent** | Canonical expr/stmt nodes have no cleanup-plan fields yet; verifier cannot enforce plans that are not in the graph. Track as firewall debt; add with Sema facts, not fake empty checks. |
| Stable cross-module references | **Absent** | No stable-key / foreign-module reference validation in `asCASTVerify`. |
| Sealed immutable publication invariants | **Partial** (consumer-side only) | Enum `asAST_VERIFY_UNSEALED_PUBLICATION` exists (`as_ast_kind.h` ~L109). CodeGen rejects unsealed input (`as_bytecode_codegen.cpp` ~L1367–1371). **Verifier itself never emits** `UNSEALED_PUBLICATION`; publication paths can still Seal incomplete graphs that pass table hygiene. |
| Qualifier legality (`as_ast_type.cpp`) | **Partial** | Accepts direction ∈ `{0, IN, OUT, INOUT}` only (~L5–12). Does **not** reject unknown bits, **direction-without-reference**, auto-handle-without-handle, illegal void+handle/reference. |

Also still absent: dangling expr children; expr-id mismatch (above).

---

## 4. Exact TDD cases to add next (bite-sized)

Add failing tests first; then implement the minimum check. Prefer Verifier / Context / Type prefixes already used by Wave C.

### VerifierTests (`AngelscriptNativeCanonicalASTVerifierTests.cpp`)

1. **`RejectsExprIndexMismatch`**  
   - Setup: TU + `CreateExpr(...)`; corrupt `expr->id = asASTExprId(99)` via unsealed non-const `GetExpr`.  
   - Expect: `asCASTVerify` → `asAST_VERIFY_FOREIGN_ID`, detail token **`expr-id`** (mirror `"stmt-id"`).

2. **`RejectsParentChildNotBidirectional`**  
   - Setup: parent P, child C with `C->parent = P`, but `P->children` does **not** list C (or lists D while D->parent ≠ P).  
   - Expect: `asAST_VERIFY_INVALID_CHILD` (or a stable new category if introduced), detail e.g. **`decl-parent-child`**.

3. **`RejectsBreakTargetNotAncestor`**  
   - Setup: two sibling loops; `break` under loop A with `target` = loop B.  
   - Expect: `asAST_VERIFY_WRONG_KIND` or `INVALID_CHILD`, detail e.g. **`break-ancestor`**.

4. **`RejectsExprMissingExactType`** (after deciding mandatory-type policy)  
   - Setup: expr with cleared/invalid `type` (and non-error kind).  
   - Expect: `asAST_VERIFY_INVALID_TYPE`, detail **`expr-type`** / **`expr-value-category`**.

5. **`RejectsExprOperandWrongKind`** (small slice)  
   - Setup: binary/call-shaped expr whose `children` include a stmt id smuggled as expr, or wrong child kind.  
   - Expect: `asAST_VERIFY_WRONG_KIND` / `INVALID_CHILD`, detail **`expr-operand`**.

Do **not** add `RejectsCallWithoutResolvedDecl`.

### ContextTests (`AngelscriptNativeCanonicalASTContextTests.cpp`)

6. **`SnapshotGetContextIsConstOnly`** (compile-time and/or runtime)  
   - Setup: build+seal context, wrap `asCASTSnapshot`.  
   - Expect: only const `GetContext()`; sealed snapshot cannot obtain non-const `GetDecl` that mutates (null or no mutable overload).

7. **`SealedSourceManagerNotMutablyExposed`**  
   - Setup: sealed context.  
   - Expect: construction APIs / non-const SourceManager unavailable on sealed/snapshot path (exact API shape TBD with friend/builder).

### TypeTests (`AngelscriptNativeCanonicalASTTypeTests.cpp`)

8. **`RejectsDirectionWithoutReference`**  
   - Setup: `InternPrimitive(ttInt, asAST_QUAL_IN)` (and OUT / INOUT without `asAST_QUAL_REFERENCE`).  
   - Expect: **invalid** QualType (`!IsValid()`), once `asASTQualifiersAreValid` tightens.

9. **`RejectsAutoHandleWithoutHandle`** / **`RejectsIllegalVoidQualifiers`** / **`RejectsUnknownQualifierBits`**  
   - Same pattern; expect intern failure.

---

## 5. Hard no — CALL/CONSTRUCT `resolvedDecl` seal firewall

**Do not** require `asAST_EXPR_CALL` / `asAST_EXPR_CONSTRUCT` to carry `resolvedDecl` inside `asCASTVerify` / `Seal`.

- Tried; broke BodySema / CodeGen seals; crashed `CodeGenEmitsFuncdefCallAndLambda` via `asCScriptEngine::~` AV; **reverted**.
- Today’s production graphs still create Call nodes without callees; they must seal.
- Wave D/B-remain must put callees into production graphs; the verifier must **not** fail-closed on incomplete Call nodes now.
- Allowed later: if `resolvedDecl.IsValid()`, check dangling (already ~L182–184) and eventually kind/signature **when present** — never “missing callee ⇒ verify fail” in Wave C.

---

## 6. Qualifier tightening — Type tests that must update **with** the change

`asASTQualifiersAreValid` today treats direction-without-reference as valid.  
`PrimitiveEnumObjectAndQualifierCanonicalization` currently expects that:

```text
AngelscriptNativeCanonicalASTTypeTests.cpp ~L37-40
  InOut = InternPrimitive(ttInt, asAST_QUAL_INOUT | asAST_QUAL_REFERENCE)  // stays valid
  BadDir = InternPrimitive(ttInt, asAST_QUAL_IN)                           // today expects IsValid()
  ASSERT_THAT(IsTrue(BadDir.IsValid(), TEXT("in-only param dir is valid")));
```

**When direction-without-reference is rejected, update this assertion in the same change** (expect `!BadDir.IsValid()`, retarget message). Do not silently flip production validation and leave the test green by coincidence.

Also add (same Type test method or siblings), not present today:

- unknown qualifier bits → invalid
- `asAST_QUAL_AUTO_HANDLE` without `asAST_QUAL_HANDLE` → invalid
- void + handle/reference (and other illegal void quals) → invalid

Keep valid: `asAST_QUAL_INOUT | asAST_QUAL_REFERENCE` (~L37–38), plain/const primitives (~L22–24, L46).

No other CanonicalAST Type test currently asserts `asAST_QUAL_IN` alone succeeds. Shadow/Sema tests use const/handle/inout+ref paths and are not the BadDir oracle.

---

## 7. File list the later C implementer may touch

**May touch**

| Path | Why |
| --- | --- |
| `.../source/as_ast_context.h` | Private non-const Get*; seal SourceManager; construction APIs (`AddDeclChild` / `SetBody` / `SetTarget`); friend/builder |
| `.../source/as_ast_context.cpp` | Same |
| `.../source/as_ast_public_view.h` | `GetContext()` const-only |
| `.../source/as_ast_public_view.cpp` | Match header; no mutable leak |
| `.../source/as_ast_verifier.h` | Result/detail only if needed |
| `.../source/as_ast_verifier.cpp` | R08 firewall checks (**except** CALL-without-callee) |
| `.../source/as_ast_kind.h` | New verify categories only if existing tokens are insufficient |
| `.../source/as_ast_type.h` / `as_ast_type.cpp` | Tighten `asASTQualifiersAreValid` **after** B-remain allows shared-file write |
| `.../source/as_decl.h` / `as_stmt.h` / `as_expr.h` | Friend/builder or documentation-only; keep POD placement-new |
| Optional `as_ast_arena.h` / `as_ast_arena.cpp` | Extract only if desired; arena already works inside context |
| `AngelscriptNativeCanonicalASTContextTests.cpp` | 13.4 tests |
| `AngelscriptNativeCanonicalASTVerifierTests.cpp` | 13.5 tests |
| `AngelscriptNativeCanonicalASTTypeTests.cpp` | Qualifier oracle updates **with** tightening |
| `AngelscriptNativeCanonicalASTDumpTests.cpp` | Only if construction API / arena split changes dump fixtures |
| `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptCanonicalASTSnapshotReloadTests.cpp` | Adapt to const `GetContext()` |
| `Plugins/Angelscript/Standalone/CMakeLists.txt` + Standalone architecture test source list | Only if new `as_ast_arena.cpp` is added |

**Must not touch (Wave C remainder)**

| Path | Why |
| --- | --- |
| `as_sema_expr.cpp` | Wave B owns it until B-remain is green |
| `as_sema.cpp` / `as_sema_decl.cpp` / `as_sema_stmt.cpp` / `as_sema_lifetime.*` | B-owned |
| `as_bytecode_codegen.cpp` | Wave D |
| `as_module.cpp` / `as_builder.cpp` / `Core/angelscript.h` | E/F/G / collision matrix — only read unless a const-`GetContext` call site literally will not compile (prefer fixing snapshot API + tests first) |
| Re-adding CALL-without-`resolvedDecl` verify | Hard no (§5) |

`asCSema::GetContext()` returning `asCASTContext&` (`as_sema.h` ~L68) is the **unsealed builder** surface — keep it; do not “fix” Sema by forcing const Context during construction.

---

## 8. Recommended first three TDD tests

1. **`RejectsExprIndexMismatch`** (Verifier) — closes the obvious half of “stmt/expr indices”; mirrors landed stmt-id; tiny diff.  
2. **`SnapshotGetContextIsConstOnly`** (Context / HotReload canary) — forces the last clear R07 mutable-snapshot hole without growing the verifier.  
3. **`RejectsDirectionWithoutReference`** (Type) — drives `asASTQualifiersAreValid` tightening and updates `BadDir` in the same commit.

Then: bidirectional parent/child, break-ancestor, missing expr type/value category, operand kinds — still required for 13.5, but after the three above.

---

## 9. Stale map corrections (do not re-execute)

From `attachments/wave-c-g-file-map.md` Wave C “Current wrong functions” — **outdated**:

| Stale claim | Current truth |
| --- | --- |
| Public `DestroyAll` + per-node `asDELETE` | `DestroyAll` is private; batch arena free |
| `Create*` uses per-node `asNEW` | Placement-new into 64KiB slabs |
| Verifier does not check stmt id vs table index | **Does** (`stmt-id`); expr-id still missing |
| ContextTests never inspect slab | `ArenaContains` / `GetArenaUsedBytes` asserted |
| `BulkDestructionClearsTables` calls public `DestroyAll` | No longer does |

---

## 10. Stay `[ ]` until

- No mutable `asCASTContext*` on snapshot/backend surfaces.  
- Sealed path is const traversal only (SourceManager + nodes).  
- `asCASTVerify` covers R08 graph firewall items that today’s node schema can express (**except** CALL-without-callee).  
- Qualifier intern rejects illegal combinations; Type `BadDir` updated in lockstep.  
- Context / Verifier / Type prefixes green after those tests; BodySema/CodeGen seals still green without callee-required verify.
