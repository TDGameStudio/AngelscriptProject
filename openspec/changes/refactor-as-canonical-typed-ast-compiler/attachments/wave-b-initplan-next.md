# Wave B research — tenth-pass F1/F4 Sema-owned typed member initializer plan

> **Status 2026-08-22:** dump bite **LANDED** (SemaAuthority **240/240**, ctor `init=` Assign of interned `40+1`, atoi helper deleted). Execute is **not** this file — exclusive UBT is `wave-b-initplan-exec.md` (`Entry()` still **got=0**). Do not re-implement dump. Do not check 5.4 / 5.7 / 5.8 / 13.2.

Worktree: `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`).
Change: `refactor-as-canonical-typed-ast-compiler`.
Package: **B-initplan-next**. Historical research map for the dump bite. Live exclusive: `wave-b-initplan-exec.md`.

Companions: `async-work.md` §3 F1/F4 and §6; `reviews/implementation-rereview-2026-08-22-tenth-pass.md` F1 and F4; `tasks.md` 5.4 / 5.7 / 5.8 (original text, boxes stay `[ ]`).

LLVM/Clang is a **shape** reference only. Do not link Clang/LLVM. No Unreal types in fork frontend files.

This map is **not** a 5.4 / 5.7 / 5.8 / 13.2 close. Do not check those boxes because this file exists, because RED tests exist, or because the later bite goes GREEN.

---

## Header

| Field | Value |
| --- | --- |
| Date | 2026-08-22 |
| Mode | Research map. Later exclusive UBT TDD. One bite, not whole 5.7/5.8 |
| Gate | F2 mutex released. Isolated VALUE-temp `Value=41` stays GREEN as regression, not as InitPlan evidence |
| Do not mark | **5.4 / 5.7 / 5.8 / 13.2 / 5.5 / 5.6 / 5.9 / 9.5 / 4.2 / 13.1 / 13.6** |
| Commands (later UBT only) | `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` from `D:\as-cta`, always `-NoXGE` |

---

## 0. Honesty — `Value=41` GREEN is atoi, not a typed InitPlan

`IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace` (`AngelscriptNativeCanonicalASTVmMatrixTests.cpp:597-681`) is GREEN after the 18:11 CodeGen patch (`wave-b-54-remain-iso2` **4/4**, Semantics **12/12**).

Fixture:

```angelscript
struct FValue
{
    int Value = 41;

    FValue()
    {
        Trace(1);
    }

    ~FValue()
    {
        Trace(2);
    }
}

int Entry()
{
    return FValue().Value + 1;
}
```

That **42** is **not** a Sema-owned typed initializer plan.

Pre-patch: user `FValue()` skipped `FillGeneratedConstructorDefaults()`. CodeGen registered layout and emitted only `Trace(1)`. `FValue().Value` read an uninitialized local. Isolated single-run lucked `42`; Semantics prefix got `13733`.

Post-cutoff tactical patch: `EmitConstructorMemberDefaults()` walks `member->defaultArg` and `atoi()`-writes integer/bool properties **before** the user body. `int Value = 41` therefore executes 42.

Tenth-pass F1/F4: backend re-parses a C string; only integer/unsigned/bool; `atoi("40+1")` is 40; generated ctor already has atoi-assigns in its body so the new emitter can double-write; property miss is silent `continue`.

**Do not** treat Isolated GREEN, `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes` GREEN (`Value=41`, generated ctor, WRTV4), or `CanonicalConstGlobalBinaryInitEvaluatesFortyPlusOne` GREEN (`default=41` string + `strtoll`) as F1/F4 close.

**Do not** propose expanding `atoi` / `strtoll` / `IntegerInitText` so they accept `40+1`. That greets the next fixture and leaves the string protocol in place.

---

## 1. Clang shape (do not link)

Quote shape only. Local LLVM: `Reference/llvm-project`. This project does not compile or link Clang.

`CXXCtorInitializer` is owned by the constructor **declaration**, not by the body `CompoundStmt`. The init is a typed `Expr*`:

```2369:2378:Reference/llvm-project/clang/include/clang/AST/DeclCXX.h
class CXXCtorInitializer final {
  /// Either the base class name/delegating constructor type (stored as
  /// a TypeSourceInfo*), an normal field (FieldDecl), or an anonymous field
  /// (IndirectFieldDecl*) being initialized.
  llvm::PointerUnion<TypeSourceInfo *, FieldDecl *, IndirectFieldDecl *>
      Initializee;

  /// The argument used to initialize the base or member, which may
  /// end up constructing an object (when multiple arguments are involved).
  Stmt *Init;
```

`CXXConstructorDecl` iterates that list (`inits()` / `init_begin()` / `init_end()` at `DeclCXX.h:2686-2717`). In-class NSDMI becomes a ctor initializer; dump shape:

```
CXXConstructorDecl 'Record'
|-CXXCtorInitializer 'm_i'
| | `-IntegerLiteral
|-CXXCtorInitializer 'm_i2'
| | `-CXXDefaultInitExpr
| |   `-IntegerLiteral
`-CompoundStmt
```

(`clang/unittests/AST/ASTTraverserTest.cpp` ~1240–1252.)

CodeGen **emits the plan, then the body**. It does not re-parse field default text:

```865:873:Reference/llvm-project/clang/lib/CodeGen/CGClass.cpp
  // Emit the constructor prologue, i.e. the base and member
  // initializers.
  EmitCtorPrologue(Ctor, CtorType, Args);

  // Emit the body of the statement.
  if (IsTryBody)
    EmitStmt(cast<CXXTryStmt>(Body)->getTryBlock());
  else if (Body)
    EmitStmt(Body);
```

`InitListExpr` (`Expr.h:5299+`) is the typed list of initializer **expressions** (syntactic vs semantic form). Adopt the principle: Sema owns typed init exprs; CodeGen only executes them.

Adopt for this bite:

- Each constructor (user and generated) has a Sema-owned init-expr list on `DECL_CONSTRUCTOR`.
- Member default initializers run in **declaration order** before the user `CompoundStmt`.
- The init is interned `Assign` (primitive) or `Construct` (later object bite) of a typed `Expr`, not `defaultArg` text.
- Dump observes `init=` on the Constructor DECL (same observer style as ForStmt `init=`/`body=`/`incr=`).

Exclude this bite: Clang classes/libraries; in-source `: mem()` syntax (not current fork); object/enum/list construction; exceptional cleanup POD; public snapshot ABI; Wave E–G.

---

## 2. Live file:line (current tree; not `as_sema.cpp`)

`FillGeneratedConstructorDefaults` / `EnsureGeneratedLifecycle` are **not** in `as_sema.cpp`. They live in `as_sema_decl.cpp`. `as_sema.cpp` owns `ActOnConstructorDecl` and the F4 global **string fold**.

### 2.1 Member default is a first-integer token string

```410:451:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp
static asCString IntegerInitText(asCScriptCode* script, asCScriptNode* node)
{
    // FindConstantNode → first snConstant / ttIntConstant
    // skip leading '=' / whitespace
    // copy optional '-' then decimal digits only; stop at '+' / space
}
```

WalkDecls class member (`:1490-1496`): `SetDefaultArg(existingVar, IntegerInitText(...))`. For `int Value = 40 + 1` that is **`"40"`**, not a typed Binary.

Globals are a different string protocol (`as_sema.cpp:611-631` `ActOnGlobalVarInit`): intern expr → `EvalIntegerConst` → `Format("%d")` → `SetDefaultArg`. `CanonicalConstGlobalBinaryInitEvaluatesFortyPlusOne` already GREENS `default=41` + `strtoll`. **Do not retarget that test this bite.** It is F4 research, not this TDD.

`asCDecl` (`as_decl.h:13-37`) has `body`, `defaultArg` (`asCString`), **no** init-expr list.

### 2.2 User ctor skip

```657:732:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp
static void FillGeneratedConstructorDefaults(...)
{
    // for each DECL_VAR with defaultArg:
    //   atoi(member->defaultArg) → ActOnIntegerLiteral → ActOnDeclRef → ActOnAssign
    //   ActOnExprStmt into stmts
    // SetBody(ctor, ActOnBlock(...))   // overwrites body
}

static void EnsureGeneratedLifecycle(...)
{
    // hasCtor / generatedCtor (TRAIT_GENERATED only)
    // if (!hasCtor) synthesize generated ctor
    // if (generatedCtor.IsValid()) FillGeneratedConstructorDefaults(...)
    // user FValue() ⇒ hasCtor=true, generatedCtor invalid ⇒ Fill does not run
}
```

Called after class `}` (`as_sema_decl.cpp:1297-1318`). User ctor body is attached separately (`AttachParsedFunctionBody` `:1213-1238`) and is only the user statements (`Trace(1)` / `Value = Value + 1`).

`as_sema.cpp:338-344` `ActOnConstructorDecl` creates the DECL. It does not attach member inits.

### 2.3 CodeGen atoi before body (the Isolated GREEN)

```484:487:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
            if( decl->kind == asAST_DECL_CONSTRUCTOR )
            {
                EmitConstructorMemberDefaults(decl);
            }
```

```781:818:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
        void EmitConstructorMemberDefaults(const asCDecl* ctor)
        {
            // walk parent class DECL_VAR with defaultArg
            // skip non integer/unsigned/bool (silent continue)
            // bits = atoi(member->defaultArg)
            // SetConst + ADDSi + EmitWriteValue
        }
```

`atoi("41")` → 41 (Isolated GREEN). `atoi("40")` / `atoi("40+1")` → 40.

Generated ctor: Fill already stuffed atoi-assigns into `body`; emitter writes them **again** before `EmitStmt`. Double-write of the same integer, still not a typed plan.

### 2.4 Global string parse (F4 sibling, not this bite's GREEN)

```3177:3191:Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp
            if( prop && child->defaultArg.GetLength() && dataType.IsIntegerType() )
            {
                const char* text = child->defaultArg.AddressOf();
                char* end = 0;
                const asINT64 parsed = strtoll(text, &end, 10);
                if( text == 0 || end == text || (end && *end != 0) )
                {
                    failed = true;
                    error = asNOT_SUPPORTED;
                    // ...
                }
```

Keep as later F4. This bite deletes **member** `atoi`, not global `strtoll`.

---

## 3. Exact next TDD bite (ONE bite)

Two new `TEST_METHOD`s. Same script. Dump proves the plan is typed AST on `DECL_CONSTRUCTOR`. Execute proves it runs **before** the user body and is not `atoi` of the first decimal token.

Do **not** retarget `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace`. Do **not** write `Value = 41` in the user ctor. Do **not** clear locals. Do **not** add `@` or script `funcdef`. Do **not** use mutable script globals as counters.

### 3.1 Shared fixture (no `@`, no script funcdef)

```angelscript
struct FValue
{
    int Value = 40 + 1;

    FValue()
    {
        Value = Value + 1;
    }
}

int Entry()
{
    FValue Object;
    return Object.Value;
}
```

Why this source:

| Path | `Value` after ctor | `Entry()` |
| --- | --- | --- |
| Sema-owned typed `40+1` **then** user `Value = Value + 1` | 42 | **42** |
| CodeGen `atoi(IntegerInitText)` = `atoi("40")` then user body | 41 | 41 |
| No member init (pre-18:11 user-ctor skip) | uninit + 1 | garbage / luck |
| Expand atoi to eval `40+1` in CodeGen | 42 | 42 — **forbidden**; dump stays RED |
| Hand-write `Value = 41` in the user ctor | 42 | 42 — **forbidden**; not a default initializer |
| Fold only `default=41` string (global F4 protocol) | 42 via `atoi("41")` | 42 — **forbidden**; dump has no ctor `init=` Assign of interned Binary/IntegerLiteral 40 |

User-body `Value = Value + 1` is the **before-body** oracle. Do not remove it to make Isolated-style `Value+1` in `Entry()` hide the atoi-40 result.

### 3.2 Dump test — append to SemaAuthority

**File:** `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`  
**Class:** `FCanonicalASTSemaAuthorityTests`  
**Prefix:** `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`  
**Append:** after `ParserSameNameParamOnDifferentFunctionsIsNotDuplicate` (ends `:11245`), before the class `};` at `:11246`.

**Name:** `UserCtorMemberDefaultFortyPlusOneRecordsTypedAssignBeforeBodyOnCompileSealPath`

Shape (compile→seal, same style as `LocalDeclAndExprStmtAreSiblingsOnCompileSealPath` / `CanonicalConstGlobalBinaryInitEvaluatesFortyPlusOne` dump half):

- `SetCompilerPipeline(CANONICAL)`
- `SetASTRetentionPolicy(asAST_RETAIN_SNAPSHOT)`
- module name `SemaUserCtorInitPlan`
- section `SemaUserCtorInitPlan.as`
- `Build()==0`
- `DumpSealedCanonicalAst`

**Must assert (all of these):**

1. `DECL` line `kind=Constructor` `name=FValue` contains `init=` with at least one id `> 0`.
2. Each `init=` id names an `EXPR` `kind=Assign` (primitive member default → Assign; do not accept a body-only Assign).
3. Dump contains `kind=IntegerLiteral` with `literal=40` **and** `kind=Binary` with `literal=+`.
4. User-body mutation remains a **body** `ExprStmt` Assign (`Value = Value + 1`). Constructor `init=` Assign is **not** that body statement.
5. `kind=Var name=Value` may still print `default=` as source spelling. **`default=40` or `default=41` alone is failure**, not success.

**Must not assert:** `safepoint=` completeness; CALL-without-callee on unsealed `asCASTVerify`; cleanup-plan POD; `default=41` as InitPlan.

**Expected RED today:**

- Constructor dump has **no** `init=` (DECL format at `as_ast_dump.cpp:210-246` has `default=` / `captures=` / `span=`, not ctor `init=`).
- User ctor AST is only the body Assign of `Value + 1`. No interned `IntegerLiteral` 40 from the member default (`IntegerInitText` stored `"40"` on the Var).
- FillGeneratedConstructorDefaults did not run.

### 3.3 Execute test — append to ProductionCodeGen

**File:** `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`  
**Class:** `FCanonicalASTProductionCodeGenTests`  
**Prefix:** `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen`  
**Append:** after `CanonicalScriptClassRegistersRefImplicitHandleNotValue` (ends `:2291`), before the class `};` at `:2292`.

**Name:** `CanonicalUserCtorMemberDefaultFortyPlusOneExecutesBeforeBody`

Shape (same engine/module helpers as `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes`):

- `SetCompilerPipeline(CANONICAL)`
- `CompileNativeModule(..., "ProdUserCtorInitPlan", ...)`
- `CanonicalExecuteInt(..., "int Entry()", Value)`
- `Value == 42`
- publisher `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` (not `COMPILER`)

Optional (do not require bytecode opcode archaeology as the pass condition): `FValue` construct behaviour exists. The execute 42 **and** the dump test together are the oracle.

**Expected RED today:** `Entry()` returns **41** (atoi `"40"` then user `+ 1`), publisher still CodeGen. Do not weaken to `>= 40`. Do not accept Isolated-style luck. If a dirty local lucks 42, the dump test still fails.

Do **not** add a third Isolated/Semantics method this bite. Isolated `Value=41` remains the regression lock.

### 3.4 Expected RED → GREEN production change

**RED** = dump missing Constructor `init=` Assign of interned `40+1`, execute 41.

**GREEN (this bite only):**

1. **Sema** interns the member default as a typed expr (`ActOnBinary`/`ActOnIntegerLiteral`/`ActOnExprFromNode` of the init node — not `IntegerInitText` / `atoi`). `ActOnAssign(ActOnDeclRef(member), initExpr)` in **declaration order**.
2. Record those Assign/Construct **exprs on every `DECL_CONSTRUCTOR`** of the class (user and `TRAIT_GENERATED`). Clang: `CXXCtorInitializer` list on the ctor, then `CompoundStmt`. Do **not** `SetBody` overwrite a user body (`FillGeneratedConstructorDefaults` `:683` is unsafe on user ctors).
3. **Dump observer:** Constructor DECL prints `init=<expr-id>[,<expr-id>…]` (`as_ast_dump.cpp` DECL loop). Mirror ForStmt named `init=`. No public snapshot / sidecar / mid-vtable Get* (Wave E/F8).
4. **CodeGen** in `Emit()` (`:484-487`): emit those interned exprs (existing `EmitExpr` of Assign/Construct), **then** `EmitStmt(decl->body)`.
5. **Delete** `EmitConstructorMemberDefaults` atoi for those members. No atoi fallback for `40+1`. No silent `continue` that “temporarily” keeps atoi.
6. **Rewrite** `FillGeneratedConstructorDefaults` off atoi + `SetBody` overwrite; generated ctor uses the same ctor `inits` list so `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes` stays GREEN after atoi dies.

Minimal new storage: `asCArray<asASTExprId> inits` on `asCDecl` plus `asCASTContext` add/get (construction API). Do **not** invent stmt-level cleanup-plan POD. Do **not** store `asCScriptFunction*` on sealed AST.

Keep `defaultArg` as diagnostic/source spelling if useful. Backends must not parse it for these members.

`ActOnGlobalVarInit` fold-to-`"%d"` / CodeGen `strtoll` stay for a **later** F4 bite. Do not expand that protocol onto members.

---

## 4. What NOT to do

- Clear / zero VM locals hoping `41` appears (`13733` already proved that is luck).
- Write `Value = 41` (or `Value = 40 + 1`) **by hand in the user ctor** to green execute.
- Keep or extend `atoi` / `strtoll` / `IntegerInitText` so `40+1` becomes 41 in the backend.
- Retarget Isolated `Value=41` or `CanonicalConstGlobalBinaryInitEvaluatesFortyPlusOne` (`default=41`) as this bite’s pass condition.
- Call `FillGeneratedConstructorDefaults` on user ctors via `SetBody` (wipes `AttachParsedFunctionBody`).
- Whole 5.7/5.8: object/handle members, global runtime init, exceptional cleanup, `try`/`catch`, `as_sema_lifetime.h/.cpp` as the deliverable.
- Wave E–G: detached/atomic module, Cache/public snapshot, SourceManager content identity, default CANONICAL, Ready/CompileFunction, HIR retirement.
- Require CALL-without-callee on unsealed `asCASTVerify`.
- Globally full-span `FindExistingExpr`. Script `funcdef` / `@` / `is` / `dictionary`. Mutable script globals as Trace counters.
- Clang/LLVM link. Second UBT in `D:\as-cta`. Check remaining OpenSpec boxes.
- Mark 5.4 / 5.7 / 5.8 / 13.2 from this map or from later prefix greens.

---

## 5. Stay-unchecked (this map is not a close)

`tasks.md` original text, boxes stay `[ ]`:

**5.4** — Add and implement explicit sequencing/single-evaluation nodes for property/index/mutation chains, short-circuit logic, conditional expressions, temporaries, and **compiler-generated values**. Prove side-effect trace parity in separate legacy/canonical Engines.

**5.7** — Add failing lifetime/cleanup tests for value objects, handles/references, constructor/destructor selection, temporary materialization/lifetime extension, deferred/out parameters, return/transfer cleanup, global initialization, exceptional cleanup, and currently rejected `try/catch` behavior.

**5.8** — Implement `as_sema_lifetime.h/.cpp` and explicit AST materialization/cleanup plans. Preserve current language rejection boundaries, VM exception behavior, destructor order, and no-cleanup-after-dead-value invariants.

This bite is **one** compiler-generated-value slice: user-ctor member default as typed Assign **before** body. Isolated traces, OpaqueValue, and atoi-`41` are not 5.4. Dump `init=` is not 5.7/5.8 lifetime. Backends still rerun Sema (F2/F3) until those packages land. **13.2** stays open.

Must-stay-green after GREEN (regression, not close): Isolated **4/4** including `IsolatedValueTemporaryCtorDtorMatchesLegacyCanonicalTrace`; `CanonicalGeneratedDefaultCtorBuildPublishesCodeGenAndExecutes`; ProductionCodeGen named rows; SemaAuthority existing methods.

---

## 6. Commands (later UBT only)

From `D:\as-cta`. Always `-NoXGE`. `RunTests.ps1` does **not** UBT — `RunBuild.ps1` first after impl. Force Runtime rebuild if UBT says up-to-date (`as_bytecode_codegen.cpp` / `as_sema_decl.cpp` often dirty-untracked): delete `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` and `Intermediate/.../AngelscriptRuntime/Module.AngelscriptRuntime*.obj`.

```powershell
Set-Location D:\as-cta
.\Tools\RunBuild.ps1 -Label wave-b-initplan -NoXGE -TimeoutMs 1800000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-initplan-sema -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label wave-b-initplan-prod -TimeoutMs 600000
.\Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics" -Label wave-b-initplan-sem -TimeoutMs 600000
```

RED labels: `wave-b-initplan-sema-red` / `wave-b-initplan-prod-red`. GREEN: drop `-red`. Semantics is must-stay-green Isolated `Value=41`, not a new method.

Do not run other command families. Do not build without `-NoXGE`.
