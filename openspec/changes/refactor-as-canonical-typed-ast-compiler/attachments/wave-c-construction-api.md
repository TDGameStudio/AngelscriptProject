# Wave C R07 — construction APIs vs sealed const traversal

**Date:** 2026-08-21  
**Worktree:** `D:\as-cta`  
**Change:** `refactor-as-canonical-typed-ast-compiler`  
**Tasks:** 2.4 / 13.4 only. Do **not** check those boxes from this plan.  
**Mode:** ready-to-execute TDD. Exclusive UBT when implementing. Do not share UBT with Wave D.

Arena / private `DestroyAll` / post-seal null non-const `Get*` / snapshot `GetContext()` const-only already landed (`attachments/wave-c-results.md`). This package finishes the remaining R07 hole: **unsealed writes go through context construction APIs; sealed/snapshot/backend surfaces are const traversal only.**

Fork root: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/`  
SDK tests: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/`  
HotReload tests: `Plugins/Angelscript/Source/AngelscriptTest/HotReload/`

Commands always from `D:\as-cta`. Only `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. `ProjectFile` comes from `AgentConfig.ini`.

---

## Goal

Sema and tests stop writing `asCDecl` / `asCStmt` / `asCExpr` fields through public non-const pointers. Unsealed mutation is `asCASTContext` construction APIs. After `Seal()`, callers cannot obtain a writable SourceManager or writable node pointer. `asCSema` keeps building graphs. Snapshots and `asCBytecodeCodeGen::Generate(const asCASTContext&, …)` stay const.

Do **not** re-implement the 64 KiB slab, public `DestroyAll`, or snapshot `GetContext()`. Those are done.

---

## Why private `GetSourceManager()` failed

Tried: make the non-const overload private, leave the const overload public:

```cpp
asCSourceManager& GetSourceManager();              // private
const asCSourceManager& GetSourceManager() const;  // public
```

`as_sema_decl.cpp` free helpers are **not** `asCSema` members and are **not** friends of `asCASTContext`. They call:

```cpp
sema->GetContext().GetSourceManager()
```

`asCSema::GetContext()` returns `asCASTContext&` (non-const, correctly — it is the unsealed builder). Overload resolution therefore **selects the non-const `GetSourceManager()` first**. Access is checked after overload resolution. C2248: cannot access private member. The compiler does **not** fall back to the const overload.

Same trap for same-name `GetDecl` / `GetStmt` / `GetExpr`. Free helpers that only *read* still fail if the non-const overload is private with the same name:

- `WalkOne` / `ActOnFunctionLike` / `WalkParameterSequence` / `WalkReturnConstants` / `ApplyFunctionTraits` in `as_sema_decl.cpp`
- `FillDefaultArguments` / `ReorderNamedArguments` in `as_sema_expr.cpp` (`asCExpr* expr = context.GetExpr(...)` then `expr->literal = ...`)

`friend class asCSema` does **not** help those free functions.

`RangeOf` today takes `asCSourceManager&` even though it only calls `MakeRange` (`as_sema_decl.cpp` ~L78–85). `StmtRange` in `as_sema_stmt.cpp` is the same. That is why a leftover public non-const `GetSourceManager()` was kept so the tree compiled (`wave-c-results.md`).

### Required shape (no same-name const/mutable pair)

Public, always const, even on a non-const context:

```cpp
const asCSourceManager& GetSourceManager() const;
const asCDecl* GetDecl(asASTDeclId id) const;
const asCStmt* GetStmt(asASTStmtId id) const;
const asCExpr* GetExpr(asASTExprId id) const;
```

Private, **different names**, used only inside `as_ast_context.cpp` to implement construction APIs:

```cpp
asCSourceManager& MutableSourceManager();
asCDecl* MutableDecl(asASTDeclId id);
asCStmt* MutableStmt(asASTStmtId id);
asCExpr* MutableExpr(asASTExprId id);
```

After `Seal()`, `Mutable*` return null / construction APIs return `asAST_VERIFY_POST_SEAL_MUTATION`. Const `Get*` keep traversing.

Do **not** keep `asCSourceManager& GetSourceManager()` as a public or private same-name overload.

---

## How Sema keeps mutating without public POD writes

**Construction APIs on `asCASTContext` are the public unsealed write path.** Free helpers, `asCSema` members, and tests all call them. They are not a second verifier: they write fields even when the resulting graph is malformed (verifier tests need that). They *do* reject post-seal mutation.

Keep `asCSema::GetContext()` as `asCASTContext&`. That is the unsealed builder handle. Do not make Sema’s context const during construction.

### Preferred: APIs only (no Sema friend required)

```text
asCSema / free helper / test
        |
        v
asCASTContext::{Create*, Intern*, AddDeclChild, SetBody, SetTarget, ...}
        |
        v
private MutableDecl / MutableStmt / MutableExpr / MutableSourceManager
        |
        v
public POD fields on arena nodes (placement-new; dump/verifier read via const Get*)
```

Sema member example (`ActOnReturnStmt`):

```cpp
const asASTStmtId id = context.CreateStmt(asAST_STMT_RETURN, owner, range);
context.SetStmtExpr(id, value);
context.SetBody(owner, id);   // keep today's "last return steals body" behavior; do not "fix" it here
```

Free helper example (`WalkOne` snFunction):

```cpp
const asASTStmtId block = sema->ActOnStmtFromNode(body, script, file, fn);
sema->GetContext().SetBody(fn, block);
```

instead of `sema->GetContext().GetDecl(fn)->body = block`.

Source range example (`WalkReturnConstants`):

```cpp
RangeOf(sema->GetContext().GetSourceManager(), file, node)
```

works once `GetSourceManager()` is const-only **and** `RangeOf` takes `const asCSourceManager&`.

Section add (`ActOnParsedDeclaration`, already an `asCSema` member):

```cpp
parsedFile = context.AddSourceSection(sectionName, asAST_SOURCE_AUTHORED,
    script->code, script->codeLength, script->lineOffset);
```

instead of `context.GetSourceManager().AddSection(...)`.

### Allowed compile-bridge (must not remain the public write path)

`friend class asCSema` plus private `Mutable*` is allowed **only** so `asCSema` *member* `ActOn*` can still compile while those members are rewritten. It does **not** unlock `as_sema_decl.cpp` / `as_sema_expr.cpp` free helpers.

If any free helper still needs a mutable SourceManager after the rename, add **named** `asCSema` wrappers that call private `Mutable*` / `AddSourceSection`:

```cpp
const asCSourceManager& asCSema::GetSourceManager() const { return context.GetSourceManager(); }
asASTFileID asCSema::AddSourceSection(...); // forwards to context
```

Free helpers then use `sema->GetSourceManager()` / `sema->GetContext().SetDefaultArg(...)`. Never `GetContext().GetSourceManager()` as a non-const reference.

Drop the friend once every write is a construction API. Do not ship “Sema pokes POD through friend” as the 2.4 close.

---

## Construction API catalog

All unsealed. First line of each: `if( RejectPostSealMutation() != asAST_VERIFY_OK ) return asAST_VERIFY_POST_SEAL_MUTATION;` (or invalid `asASTFileID` for `AddSourceSection`). Missing *target node* → `asAST_VERIFY_DANGLING_ID`. Child/target *IDs* are not validated here (verifier tests attach `asASTDeclId(99)`).

| API | Replaces | Callers today |
| --- | --- | --- |
| `asASTFileID AddSourceSection(logicalKey, origin, bytes, byteCount, lineOffset=0)` | `GetSourceManager().AddSection` | `asCSema::ActOnParsedDeclaration` |
| `int SetDeclType(asASTDeclId, const asCQualType&)` | `decl->type =` | `ActOnFunctionDecl`, `CreateTypedDecl`, `ActOnVarDecl`, import type |
| `int SetBody(asASTDeclId, asASTStmtId)` | `decl->body =` | `ActOnReturnStmt`, lambda/function `WalkOne`, CodeGen tests |
| `int AddDeclTrait(asASTDeclId, asDWORD)` | `decl->traits \|=` | `ApplyFunctionTraits`, generated ctor/dtor/accessor, lambda, list-pattern |
| `int SetDeclTraits(asASTDeclId, asDWORD)` | `decl->traits =` | Shadow perturbation |
| `int SetDeclName(asASTDeclId, const char*)` | `decl->name =` | lambda rename |
| `int SetStableKey(asASTDeclId, const char*)` | `decl->stableKey =` | `FinishDecl` |
| `int AddDependency(asASTDeclId, const char*)` | `decl->dependencies.PushLast` | `RecordDependency` |
| `int ClearDeclDependencies(asASTDeclId)` | `dependencies.SetLength(0)` | Shadow perturbation |
| `int SetOrigin(asASTDeclId, const char*)` | `decl->origin =` | import, list-pattern |
| `int AddBase(asASTDeclId, asASTDeclId)` | `decl->bases.PushLast` | class bases |
| `int SetDefaultArg(asASTDeclId, const char*)` | `param->defaultArg =` | `WalkParameterSequence` |
| `int SetDeclParent(asASTDeclId, asASTDeclId)` | `decl->parent =` | Shadow perturbation |
| `int SetDeclRange(asASTDeclId, const asCSourceRange&)` | `decl->range =` | Shadow `offset = 42` |
| `int AddDeclChild(asASTDeclId parent, asASTDeclId child)` | `children.PushLast` | Verifier foreign-child; `CreateDecl` already parent-links |
| `int ClearDeclChildren(asASTDeclId)` | `children.SetLength(0)` | `RejectsParentChildNotBidirectional` |
| `int SetDeclKind(asASTDeclId, asEASTDeclKind)` | `decl->kind =` | `RejectsDanglingWrongKindAndInvalidRange` |
| `int SetStmtExpr(asASTStmtId, asASTExprId)` | `stmt->expr =` | most `ActOn*` stmts, Dump, BodySema |
| `int SetTarget(asASTStmtId, asASTStmtId)` | `stmt->target =` | break/continue/case, BodySema, Verifier |
| `int SetStmtDecl(asASTStmtId, asASTDeclId)` | `stmt->decl =` | decl-stmts in `as_sema_stmt.cpp`, CodeGen |
| `int AddStmtChild(asASTStmtId, asASTStmtId)` | `stmt->children.PushLast` | blocks, if/loop/switch/case |
| `int ClearStmtChildren(asASTStmtId)` | `stmt->children.SetLength(0)` | while/do/for fill-in |
| `int SetStmtId(asASTStmtId, asASTStmtId)` | `stmt->id =` | `RejectsStmtIndexMismatch` |
| `int AddExprChild(asASTExprId, asASTExprId)` | `expr->children.PushLast` | every `ActOn*` expr, Verifier operand |
| `int SetLiteral(asASTExprId, const char*)` | `expr->literal =` | literals, call names, materialize/cleanup, named/default args |
| `int SetLiteralBits(asASTExprId, asQWORD)` | `expr->literalBits =` | int/bool literals, BodySema cases |
| `int SetResolvedDecl(asASTExprId, asASTDeclId)` | `expr->resolvedDecl =` | decl-ref, call, construct, cleanup |
| `int SetExprType(asASTExprId, const asCQualType&)` | `expr->type =` | only if a writer needs it; `CreateExpr` already sets type |
| `int SetExprId(asASTExprId, asASTExprId)` | `expr->id =` | `RejectsExprIndexMismatch` |

`CreateDecl` already pushes the new id onto `parent->children`. Do not double-add in Sema. `AddDeclChild` exists for extra/malformed edges.

Return `int` using existing `asAST_VERIFY_*` tokens. Do not invent a parallel error enum.

Keep node fields **public POD** for placement-new (`as_decl.h` / `as_stmt.h` / `as_expr.h`). Dump and verifier keep reading through `const asCDecl*`. Optional one-line comment: writers use `asCASTContext` construction APIs. Do **not** spend this wave making fields private.

---

## File map

### Create

None. Do not extract `as_ast_arena.*`. Arena already lives in `asCASTContext`.

### Modify (fork)

| Path | What |
| --- | --- |
| `.../source/as_ast_context.h` | Construction API catalog; const-only public `GetDecl`/`GetStmt`/`GetExpr`/`GetSourceManager`; private `Mutable*` with different names; **no** public `DestroyAll`; **no** same-name mutable overloads |
| `.../source/as_ast_context.cpp` | Implement APIs via `Mutable*` + `RejectPostSealMutation`; `AddSourceSection` forwards to `sourceManager.AddSection` only when unsealed |
| `.../source/as_decl.h` / `as_stmt.h` / `as_expr.h` | Comment only if needed. Keep POD. No Unreal types |
| `.../source/as_sema.h` | Keep `asCASTContext& GetContext()`. Optional `GetSourceManager() const` / `AddSourceSection` wrappers **only** if a free helper still cannot call the context APIs |
| `.../source/as_sema.cpp` | Every `GetDecl`/`GetStmt`/`GetExpr` **write** → construction API (`SetDeclType`, `SetBody`, `SetStmtExpr`, `AddExprChild`, `SetLiteral`, `SetLiteralBits`, `SetResolvedDecl`, `SetTarget`, `AddStmtChild`, `SetStableKey`, `AddDependency`). Reads stay on const `Get*` |
| `.../source/as_sema_lifetime.cpp` | `SetLiteral` + `AddExprChild` + `SetResolvedDecl` |
| `.../source/as_sema_stmt.cpp` | `SetStmtDecl` / `SetStmtExpr` / `ClearStmtChildren` / `AddStmtChild`; `StmtRange(const asCSourceManager&, ...)` |
| `.../source/as_sema_expr.cpp` | string-literal / init-list / default / named-arg writes; free helpers call `SetLiteral` / `AddExprChild`, never `asCExpr*` |
| `.../source/as_sema_decl.cpp` | Free helpers: `RangeOf(const asCSourceManager&, ...)`; `GetContext().GetSourceManager()` only as const; `SetBody` / `AddDeclTrait` / `SetDeclName` / `SetDefaultArg` / `SetOrigin` / `SetDeclType` / `AddBase`; `ActOnParsedDeclaration` uses `AddSourceSection` |

`wave-c-g-file-map.md` “Do not rewrite Sema” is **stale for this remainder**. Unused construction APIs leave 2.4 `[ ]`. Wave B SemaAuthority dumps are already 22/22; this wave may edit Sema files to route writes. Do not change lookup/overload/type policy while doing it.

### Modify (tests)

| Path | What |
| --- | --- |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTContextTests.cpp` | New construction + SourceManager tests; retarget `ArenaOwnershipSealAndForeignIds` (const `GetDecl` stays valid after seal) |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp` | Replace every `Fn->children.PushLast` / `Broken->kind =` / `Block->id =` / `Lit->id =` / `TuDecl->children.SetLength(0)` / `LoopAStmt->children` / `BrkStmt->target` / `Bin->children.PushLast` |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTDumpTests.cpp` | `SetDeclType` / `SetBody` / `SetLiteral` / `SetStmtExpr` |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp` | `SetStmtDecl` / `SetBody` (~L343–360, ~L404, ~L445–482) |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTBodySemaTests.cpp` | `SetTarget` / `SetLiteral` / `SetLiteralBits` / `SetStmtExpr` / `AddStmtChild` |
| `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTShadowTests.cpp` | `SetDeclParent` / `SetDeclType` / `SetDeclTraits` / `SetDeclRange` / `ClearDeclDependencies` + `AddDependency` |

HotReload tests already walk `asIASTSnapshot` / const context. Touch only if a compile breaks.

### Must not touch

| Path | Why |
| --- | --- |
| `as_bytecode_codegen.cpp` / production `as_module.cpp::Build` / `as_builder.cpp` | Wave D. `Generate` already takes `const asCASTContext&` |
| `Core/angelscript.h` | Wave E |
| `as_ast_verifier.cpp` R08 remainder | 2.8 / 13.5. Do not add CALL-without-callee |
| `as_ast_type.cpp` qualifier intern | Already tightened |
| `as_ast_public_view.h` `GetContext` | Already const-only |
| Standalone `CMakeLists.txt` | No new TU |
| Unreal types (`FString`, `TArray`, `UObject`, `TEXT`) in fork files | Hard no |

---

## Bite-sized TDD tasks

Do not implement several tasks in one unverified jump. After each GREEN, the named prefix must compile and pass before the next rewrite.

All commands from `D:\as-cta`.

### Task 1 — RED: construction APIs and const-only signatures (Context tests)

**File:** `AngelscriptNativeCanonicalASTContextTests.cpp`

Add:

1. `ConstructionApisWriteAndSealGate`  
   Unsealed: `CreateTranslationUnit` → `CreateDecl` function → `CreateStmt` return → `SetBody` → `SetStmtExpr` → `CreateExpr` literal → `SetLiteral` / `SetLiteralBits` → `AddExprChild` on a dummy unary if needed → `AddSourceSection` with a tiny buffer → `Seal()==0`.  
   After seal: `SetBody` / `AddDeclChild` / `SetTarget` / `AddSourceSection` return `asAST_VERIFY_POST_SEAL_MUTATION` or invalid file id. Const `GetDecl` / `GetSourceManager` still observe the pre-seal graph.

2. `GetDeclAndSourceManagerAreConstOnly` (compile-time)

```cpp
static_assert(std::is_same<decltype(std::declval<asCASTContext&>().GetDecl(asASTDeclId())), const asCDecl*>::value,
	"asCASTContext::GetDecl must be const-only");
static_assert(std::is_same<decltype(std::declval<asCASTContext&>().GetStmt(asASTStmtId())), const asCStmt*>::value,
	"asCASTContext::GetStmt must be const-only");
static_assert(std::is_same<decltype(std::declval<asCASTContext&>().GetExpr(asASTExprId())), const asCExpr*>::value,
	"asCASTContext::GetExpr must be const-only");
static_assert(std::is_same<decltype(std::declval<asCASTContext&>().GetSourceManager()), const asCSourceManager&>::value,
	"asCASTContext::GetSourceManager must be const-only");
```

Keep existing `SnapshotGetContextIsConstOnly`.

**Expect RED:** missing identifiers `SetBody` / `AddSourceSection` / … and/or static_assert C2338 (`'asCASTContext::GetDecl must be const-only'`) while non-const overloads remain. Same pattern as snapshot `GetContext` RED `20260821_155516`.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Context" -Label wave-c-construction-context-red -TimeoutMs 600000
```

If UBT adaptive-skips a header-only change, force Runtime rebuild:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-construction-red -TimeoutMs 1800000 -NoXGE
```

Then re-run the Context prefix.

Do **not** delete non-const `Get*` in this task if that would take the whole plugin down before Tasks 3–7. Either:

- land the static_assert now and accept a large compile-RED until Task 8, **or**
- comment the static_assert with `// enable in Task 8` and land APIs first (Task 2), then enable it when accessors die.

Preferred: **APIs in Task 2 with old Get* still public, static_assert enabled in Task 8.** Task 1 then only asserts API existence + post-seal reject, which is RED until Task 2.

### Task 2 — GREEN: implement the catalog; keep old Get* compiling

**Files:** `as_ast_context.h` / `as_ast_context.cpp`

- Add every catalog method.
- Implement via private `MutableDecl` / `MutableStmt` / `MutableExpr` / `MutableSourceManager` (add these now as private **different names**, even while public non-const `Get*` still exist).
- `AddSourceSection` must call `RejectPostSealMutation` before `sourceManager.AddSection`.
- Do not change public `Get*` yet.
- Do not extract arena. Do not public `DestroyAll`.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Context" -Label wave-c-construction-context -TimeoutMs 600000
```

Expect: old 3 Context methods + `ConstructionApisWriteAndSealGate` GREEN. Static_assert still off.

2.4 stays `[ ]` — public mutable accessors still exist.

### Task 3 — Verifier tests stop writing POD

**File:** `AngelscriptNativeCanonicalASTVerifierTests.cpp`

| Old | New |
| --- | --- |
| `Fn->children.PushLast(asASTDeclId(99))` | `Context.AddDeclChild(Fn->id, asASTDeclId(99))` (keep the decl id from `CreateDecl`) |
| `Broken->kind = asAST_DECL_INVALID` | `Kinds.SetDeclKind(id, asAST_DECL_INVALID)` |
| `Block->id = asASTStmtId(99)` | `Stmts.SetStmtId(blockId, asASTStmtId(99))` |
| `Lit->id = asASTExprId(99)` | `Exprs.SetExprId(litId, asASTExprId(99))` |
| `TuDecl->children.SetLength(0)` | `Context.ClearDeclChildren(Tu)` |
| `LoopAStmt->children.PushLast(Brk); BrkStmt->target = LoopB` | `AddStmtChild(LoopA, Brk); SetTarget(Brk, LoopB)` |
| `Bin->children.PushLast(asASTExprId(99))` | `AddExprChild(binId, asASTExprId(99))` |

Reads of `Result.detail` unchanged. Do **not** add `RejectsCallWithoutResolvedDecl`.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Verifier" -Label wave-c-construction-verifier -TimeoutMs 600000
```

Expect **8/8** (or 8 + only if you added no new verifier cases). Categories/tokens stay `FOREIGN_ID`/`expr-id`, `INVALID_CHILD`/`decl-parent-child`, `WRONG_KIND`/`break-ancestor`, `INVALID_CHILD`/`expr-operand`.

### Task 4 — Dump / CodeGen / BodySema / Shadow fixtures

Same mechanical swap. Isolated CodeGen graphs must still `Seal()` and `Generate`.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Dump" -Label wave-c-construction-dump -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label wave-c-construction-codegen -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.BodySema" -Label wave-c-construction-bodysema -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Shadow" -Label wave-c-construction-shadow -TimeoutMs 600000
```

CodeGen prefix is isolated `Generate()`, not production `Build()`. Keep it that way.

Shadow: after `SetDeclParent` / `SetDeclType` / … restore with the same APIs, not field writes. Left context must still dump `deps=Other`.

### Task 5 — `as_sema.cpp` ActOn* writers

**File:** `as_sema.cpp` (and `FinishDecl` / `RecordDependency` / `CreateTypedDecl`).

Replace every `asCDecl* decl = context.GetDecl(id); decl->field =` with the matching API. Reads (`const asCDecl* parent = context.GetDecl(...)`) stay.

`ActOnFor` increment: `CreateStmt(EXPR)` + `SetStmtExpr` + `AddStmtChild`, not `GetStmt(last child)->expr =`.

`ActOnCall` / `ActOnConstruct`: `SetResolvedDecl` + `SetLiteral` + reverse-order `AddExprChild`. **Do not** start requiring CALL `resolvedDecl` in the verifier.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Sema" -Label wave-c-construction-sema -TimeoutMs 600000
```

Plus re-run CodeGen prefix from Task 4 (those graphs go through `ActOn*`).

### Task 6 — stmt / expr / lifetime writers

**Files:** `as_sema_stmt.cpp`, `as_sema_expr.cpp`, `as_sema_lifetime.cpp`

- while/do/for fill-in: `ClearStmtChildren` + `SetStmtExpr` + `AddStmtChild`
- decl-stmt: `SetStmtDecl`
- case inners: `AddStmtChild`
- materialize/cleanup: `SetLiteral` + `AddExprChild` + `SetResolvedDecl`
- `FillDefaultArguments` / `ReorderNamedArguments` / string literal / init-list: `SetLiteral` / `AddExprChild`
- Change `StmtRange` to `const asCSourceManager&` if you already switched the local to const; otherwise wait for Task 8

`as_sema_expr.cpp:520` `asCSourceManager& manager = context.GetSourceManager()` is **read-only** (`ExprRange` / `MakeRange`). Switching it to `const asCSourceManager&` now is safe and prepares Task 8.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.BodySema" -Label wave-c-construction-body2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.CodeGen" -Label wave-c-construction-codegen2 -TimeoutMs 600000
```

### Task 7 — `as_sema_decl.cpp` free helpers (the original compile break)

**File:** `as_sema_decl.cpp`

This is the task that makes const-only SourceManager possible.

1. Change `RangeOf` to `const asCSourceManager&`.
2. Every `asCSourceManager& manager = sema->GetContext().GetSourceManager()` → `const asCSourceManager& manager = sema->GetContext().GetSourceManager()`.
3. `WalkReturnConstants` keeps `RangeOf(sema->GetContext().GetSourceManager(), ...)`.
4. `ApplyFunctionTraits`: `AddDeclTrait` instead of `decl->traits |=`.
5. `WalkParameterSequence`: `SetDefaultArg` instead of `param->defaultArg =`.
6. `ActOnFunctionLike` lambda: `AddDeclTrait` + `SetDeclName` + `FinishDecl`.
7. `ActOnLambdaFromNode` / `WalkOne` snFunction: `SetBody`.
8. import: `SetOrigin` / `SetDeclType`.
9. list-pattern: `SetOrigin` + `AddDeclTrait`.
10. generated ctor/dtor/accessor: `AddDeclTrait(..., asAST_TRAIT_GENERATED)`.
11. bases: `AddBase`.
12. `ActOnParsedDeclaration`: `context.AddSourceSection(...)` instead of `GetSourceManager().AddSection`.
13. `ActOnVarDecl` (member): `SetDeclType`.

Do **not** make the free helpers `friend` of `asCASTContext`.

If `GetContext().GetSourceManager()` still prefers a leftover non-const overload, **delete or rename that overload in Task 8**, not by adding a const_cast.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Sema" -Label wave-c-construction-decl -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-c-construction-sema-authority -TimeoutMs 600000
```

SemaAuthority must stay dump-green. Do not mark 13.2 / 5.9 from that.

### Task 8 — delete public mutable accessors; enable const-only asserts

**Files:** `as_ast_context.h` / `.cpp`, Context tests, leftover `asCDecl*` in tests/Sema.

1. Remove public non-const `GetDecl` / `GetStmt` / `GetExpr` / `GetSourceManager`.
2. Keep private `Mutable*` (different names) for construction API bodies only.
3. `friend class asCSema` is optional; if still present, grep that no member still writes `MutableDecl(id)->field`. Remove friend if unused.
4. Enable `GetDeclAndSourceManagerAreConstOnly` static_asserts from Task 1.
5. Retarget `ArenaOwnershipSealAndForeignIds`: after seal, `Context.GetDecl(Fn)` is **non-null const traversal**, not null. Post-seal mutation is `Create*` + construction APIs failing. Drop the “mutable GetDecl returns null” assert — that dual-overload behavior is gone.
6. Grep the plugin for `asCDecl*` / `asCStmt*` / `asCExpr*` from `GetDecl`/`GetStmt`/`GetExpr`. Remaining writes are bugs.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label wave-c-construction-const -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST.Context" -Label wave-c-construction-context-const -TimeoutMs 600000
```

Expect C2338 if a non-const `GetDecl` overload was reintroduced.

### Task 9 — Frontend / HotReload / Cutover honesty

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-c-construction-frontend -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.HotReload.CanonicalAST" -Label wave-c-construction-hotreload -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Cutover" -Label wave-c-construction-cutover -TimeoutMs 600000
```

Frontend CanonicalAST was **56/56** before new Context tests; the count may rise. Require zero failures. HotReload CanonicalAST **5/5**. Cutover stays honest: default **LEGACY**, `Ready()` false, CANONICAL `Build()` publisher **COMPILER**.

Do **not** run All. Do **not** run production CodeGen routing. Standalone CTest is optional (no new TU); skip unless a fork header include broke the host.

---

## Seal-gating SourceManager without breaking free helpers

| Caller | Today | After |
| --- | --- | --- |
| `WalkReturnConstants` / `WalkOne` / `ActOnFunctionLike` / `WalkParameterSequence` | `sema->GetContext().GetSourceManager()` as `asCSourceManager&` for `RangeOf` | Same call, but public API is const-only; `RangeOf(const asCSourceManager&, ...)` |
| `as_sema_stmt.cpp` / `as_sema_expr.cpp` members | `context.GetSourceManager()` for `MakeRange` | `const asCSourceManager&` |
| `ActOnParsedDeclaration` | `context.GetSourceManager().AddSection` | `context.AddSourceSection` (seal-gated) |
| Verifier / dump / CodeGen / TypedASTJIT | already const `GetSourceManager()` | unchanged |
| Snapshot test | `const asCSourceManager& Manager = Ctx->GetSourceManager()` | unchanged |

If anyone re-adds `asCSourceManager& GetSourceManager()` (even private, same name), free helpers break again or silently regain mutation. The static_assert in Task 8 is the regression lock.

`asCSourceManager::AddSection` / `RemapLogical` stay public on the manager class. The **context** is what stops handing out a mutable manager after seal. Do not hide `AddSection` on `asCSourceManager` itself in this wave (SourceManager unit tests construct a manager directly).

---

## What still keeps 2.4 / 13.4 `[ ]`

Leave both boxes unchecked until **all** of the following are true in the tree, not in this attachment:

1. Construction APIs in the catalog exist and are seal-gated.
2. Public `GetDecl` / `GetStmt` / `GetExpr` / `GetSourceManager` are const-only (no same-name mutable overload). Task 2 APIs-with-old-Get* is **not** enough.
3. Sema members **and** `as_sema_decl.cpp` / `as_sema_expr.cpp` free helpers write through those APIs. Zero `GetDecl(id)->body =` / `GetSourceManager().AddSection` on a live context.
4. Verifier / Dump / CodeGen / BodySema / Shadow tests do not write POD through raw pointers.
5. Snapshot `GetContext()` remains const-only (already landed).
6. `DestroyAll` remains private; no public reseal (already landed).
7. Arena remains slab/placement-new (already landed; do not regress to per-node `asNEW`).
8. Context + Frontend CanonicalAST + HotReload CanonicalAST + Cutover prefixes green with LEGACY default.

`tasks.md` 2.4 “why open” still claims per-node `asNEW` and public `DestroyAll`. Update that prose **only when checking the box**, to the holes above. Do not check the box from this plan file.

### Still `[ ]` even after this package (do not conflate)

| Task | Why |
| --- | --- |
| 2.8 / 13.5 | Stmt multi-ownership, full cycles, return/fallthrough/switch ordering, cleanup/live-value plans, stable cross-module refs, verifier-emitted `UNSEALED_PUBLICATION`. **Hard no:** CALL/CONSTRUCT missing `resolvedDecl` |
| 2.6 | Named Engine types still unbridged; nullptr is still `void`+handle |
| 9.x / 13.6 | Production `Build()` still `asCCompiler` |
| 10.x | Default stays `LEGACY` |

Public POD fields on nodes remain a residual (a `const_cast` could still write). Closing that is a later friend-fields change, not 2.4. R07 remainder for 2.4 is “backends and tests cannot *obtain* a mutable pointer or SourceManager.”

---

## Hard no

- Do not route production `Build()` through `asCBytecodeCodeGen::Generate()`.
- Do not set `IsCanonicalBytecodeCodeGenReady()` true.
- Do not default `ep.canonicalCompilerPipeline` / `LEGACY` → `CANONICAL`.
- Do not re-add CALL/CONSTRUCT-without-`resolvedDecl` as a seal firewall (reverted; crashed `CodeGenEmitsFuncdefCallAndLambda`).
- Do not put Unreal types in fork files (`as_ast_*`, `as_sema*`, `as_source_manager`, `as_decl.h`, `as_stmt.h`, `as_expr.h`).
- Do not resurrect public `DestroyAll` or per-node `asNEW`/`asDELETE` for Decl/Stmt/Expr/Type.
- Do not share UBT with Wave D R09.
- Do not check `tasks.md` boxes from a green Frontend prefix.
- Do not “fix” Sema by making `GetContext()` const during construction.
- Do not same-name private `GetSourceManager()` / `GetDecl()` — that is the proven C2248.

---

## Implementer grep (done when empty)

From `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source` and the CanonicalAST test dir:

```text
GetDecl(.*)->
GetStmt(.*)->
GetExpr(.*)->
GetSourceManager().AddSection
asCDecl*  = context.GetDecl
asCStmt*  = context.GetStmt
asCExpr*  = context.GetExpr
asCSourceManager& manager = .*GetSourceManager
```

Allowed leftovers: `const asCDecl*` / `const asCStmt*` / `const asCExpr*` / `const asCSourceManager&` reads; construction API implementations using `Mutable*`.
