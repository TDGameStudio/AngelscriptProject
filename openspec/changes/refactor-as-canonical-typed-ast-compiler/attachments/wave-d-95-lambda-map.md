# Wave D 9.5 — production lambda fixture map (research only)

Worktree: `D:\as-cta`. Package **D-95-lambda-map**. No fork edits. No UBT. Do **not** check `tasks.md` 9.5 / 13.3.

CANONICAL production fixture (`CanonicalLambdaBuildPublishesCodeGenAndExecutes`):

```angelscript
int F() {
  return function(int X) {
    return X + 1;
  }(41);
}
```

`d95-red` failed at **module `Build()`** (`CompileNativeModule != 0`), not at execute. Isolated Frontend CodeGen already lowers **stored** lambdas when a **host** `RegisterFuncdef` exists. Production CodeGen has **no** anonymous-function immediate-call path.

This fixture is an **anonymous function expression** + postfix arglist. It is **not** a named script `funcdef`. Do not re-enable tokenizer `funcdef` / `@` / `is`.

---

## 1. Parser / Sema intern of `function(int X){ return X + 1; }`

### Parse

| Step | File:line | What happens |
| --- | --- | --- |
| Detect | `as_parser.cpp:1584-1588`, `1695-1718` | `ParseExprValue`: identifier `function` + `(` … `)` + `{` → `ParseLambda()` |
| Node | `as_parser.cpp:1721-1807` | `CreateNode(snFunction)`. **Not** `snFuncDef`. |
| Name token | `1727-1740` | `function` consumed as `snIdentifier` child (so `FunctionNameNode` is `"function"`, not param `X`) |
| Params | `1742-1794` | Wrapped in `snParameterList`: `ParseType` + `ParseTypeMod` + `ParseIdentifier` (`int X`) |
| Incremental ActOn | `1796-1801` | `NotifySema(node)` **before** the body; `asSDeclContextScope::PushLastActed()` (`65-88`) pushes the interned lambda as current decl context |
| Body | `1803-1805` | `ParseFunctionStatementBlock()` attached as `snStatementBlock` |

BNF comment (`1721`): `LAMBDA ::= 'function' '(' [[TYPE TYPEMOD] IDENTIFIER …] ')' STATBLOCK`. **No return-type production.**

### Sema intern

| Field | Value | File:line |
| --- | --- | --- |
| Decl kind | `asAST_DECL_FUNCTION` (not `asAST_DECL_FUNCDEF`, not Method) | `as_sema_decl.cpp:724-731`, `as_sema.cpp:248-250` |
| Name | `"<lambda>"` (never `"function"`, never `"X"`) | `as_sema_decl.cpp:692-697`, `728-731` |
| Trait | `asAST_TRAIT_LAMBDA` (`1u << 9`) | `as_ast_kind.h:137`, `as_sema_decl.cpp:728-730` |
| Return type | **defaults to `int`**: no direct `snDataType` child; `ActOnQualTypeFromNode(null)` empty key → `InternPrimitive(ttInt)` | `as_sema_decl.cpp:678-684`, `as_sema_decl.cpp:332-335` |
| Param | child `asAST_DECL_PARAM` name=`X`, type=`int` via `WalkParameterList` → `snParameterList` | `as_sema_decl.cpp:521-527`, `465-518` |
| Parent | enclosing function `F`, **not** the TU. `NotifySema` / `ActOnLambdaFromNode` pass `CurrentDeclContext()` = `F` | `as_sema_decl.cpp:912-917`, `1293-1299`, `as_parser.cpp:1796-1801` |
| Body | `SetBody(fn, ActOnStmtFromNode(snStatementBlock))` on reuse or first complete walk | `as_sema_decl.cpp:919-923`, `1090-1104` |
| Stable key | `FinishDecl`: parent-qualify + `(int)` + `@<function-token offset>` when `TRAIT_LAMBDA` | `as_sema.cpp:140-223` especially `217-221` |

Reuse (no duplicate intern): `FindExistingFunctionLike` maps node name `"function"` → `"<lambda>"` and matches **the same param count/types plus `range.begin.offset == function-token pos`** (`as_sema_decl.cpp:816-847`, `904-907`). `ActOnLambdaFromNode` (`912-917`) reuses that decl.

Dump shape (already asserted): `DECL kind=Function name=<lambda> parent=<F id> key=…<lambda>(int)@… traits=` includes `asAST_TRAIT_LAMBDA`. Expression form of the lambda itself is `ActOnDeclRef(fn, intType, …)` (`as_sema_decl.cpp:925-927`, `as_sema.cpp:398-406`) — a `DECL_REF` whose `resolvedDecl` **is** the interned lambda.

Parser-action proofs (already green, do not rewrite):

- `ParserActOnLambdaDeclBeforeBodyParseFails` — `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:2669-2705`
- `ParserActOnLambdaDoesNotDuplicateOnSuccessfulParse` — same file `:2707-2763`
- `MultipleLambdasKeepDistinctStableKeys` — `:222-278`

---

## 2. Immediate call `(41)` intern

Parse: `ParseExprTerm` (`as_parser.cpp:2267-2287`) appends `ParseExprPostOp` (`2321-2370`). `(` is `ttOpenParanthesis` + `ParseArgList()`, **not** `snFunctionCall`. After the postfix, `ActOnParsedExpr(snExprTerm)` runs with context popped back to `F`.

Sema (`as_sema_expr.cpp:965-1138`, postfix call `1076-1114`):

1. Child `snExprValue`/`snFunction` → `ActOnLambdaFromNode` → `DECL_REF` with `resolvedDecl = <lambda>`.
2. Child `snExprPostOp` `ttOpenParanthesis` collects args in **source / formal** order (`1082-1085`): one child, integer `41`.
3. Callee is **`lhs->resolvedDecl`** (`1087-1098`), not `ResolveCallee` by name. That is the interned lambda decl, not `"F"` / first global / `"function"`.
4. `ActOnCall(callee, args, type, range)` (`as_sema.cpp:464-488`):
   - `SetResolvedDecl(id, callee)`
   - literal `"<lambda>:reverse-formal"`
   - **children stored reverse-formal** (`483-486`). One arg → `children = [IntegerLiteral 41]`.
   - result type from lambda decl type if valid, else the term's fallback `int` (`as_sema_expr.cpp:1106-1114`). Here both are `int`.

If `resolvedDecl` is empty, the same postfix becomes `ActOnUnary("(")` (`1116-1118`) — a sealed dump with `kind=Unary`, which `ParserActOnLambdaCallThroughRecordsCallee` (`:4872-4923`) already rejects.

**Important intern shape for CodeGen:** `snExprTerm` pushes **both** the `DECL_REF` and the `CALL` into a sequence (`as_sema_expr.cpp:1125`, `1133-1136`). `sequence.GetLength() > 1` → `ActOnSequence([DECL_REF lambda, CALL lambda], int, termRange)`. `F`'s `return` therefore typically returns a **SEQUENCE**, not a bare CALL. Dump still contains `kind=Call` `callee=` containing `<lambda>` (stableKey, `as_ast_dump.cpp:187-197`, `264-270`).

`ParserActOnLambdaCallThroughRecordsCallee` uses the same immediate-invoke source and requires Seal `0` plus a Call line with `<lambda>` and a non-empty `callee=`.

---

## 3. Legacy `asCCompiler` emit (do not copy into CANONICAL)

Anonymous function is **deferred**, not a script function id at the expr:

- `snFunction` → `ctx->SetLambda(vnode)` (`as_compiler.cpp:15685-15690`, `22864-22880`).
- Type is **undefined func handle** = `CreateObjectHandle(&engine->functionBehaviours)` (`22733-22744`), **not** a concrete funcdef, **not** `asBC_CALL`.

The **only** lowering that creates a script function is conversion **to a known funcdef**:

- `ImplicitConvLambdaToFunc` (`11521-11578`) requires `to.IsFuncdef() && ctx->IsLambda()`.
- Unique name `$<outFunc declaration>$<n>` or `$<globalVar>$<n>` (`11562-11566`) — **not** a shared `"$func"` function name. `"$func"` in dumps is the **funcdef / function-object type** (`CodeGenDumpsFuncdefHandleConversionAndOpcodes` asserts `FuncPtr` + `REFCPY` + `$func` **or** `Callback`).
- `builder->RegisterLambda` (`as_builder.cpp:5489-5538`) copies the **funcdef** return/params, disconnects the statement block, `RegisterScriptFunction` as a later-compiled `asFUNC_SCRIPT`, sets `asBUILD_ARTIFACT_INVOCATION_LAMBDA`.
- Bytecode: `asBC_FuncPtr` of that function (`as_compiler.cpp:11572`). Later invoke of a stored handle is `asBC_CallPtr` (`22261`, postfix `19304-19313`).

Immediate `(41)` on a raw lambda **does not** take that path. Postfix `ttOpenParanthesis` (`19232-19241`) requires an already-typed **funcdef or object**. A deferred lambda is `functionBehaviours` (object, not funcdef) with no `opCall` match → `TXT_EXPR_DOESNT_EVAL_TO_FUNC` / dummy. Unused lambda expr-stmt is also an error (`9419-9421`).

So legacy for this **exact** fixture is: **no hidden named `funcdef` in script**, **no direct `asBC_CALL` of a lambda id**, **no successful delegate** unless a host/funcdef conversion already happened. Official working shape is `Callback L = function(int X){…}; L(41)` after `RegisterFuncdef`.

`RegisterLambda` still walks **sibling** `snIdentifier` nodes until `snStatementBlock` (`as_builder.cpp:5494-5505`). After ParseLambda wraps params in `snParameterList`, that walk can see the `"function"` identifier and miss `X`. Canonical `WalkParameterList` uses the list node; do not “fix” `RegisterLambda` for this CANONICAL slice.

---

## 4. Does Generate already collect the lambda?

**Yes.** `CanonicalDeclIsFunctionLike` is `FUNCTION | METHOD | CONSTRUCTOR | DESTRUCTOR` (`as_bytecode_codegen.cpp:29-35`). `Generate` walks **every** decl id `1..GetDeclCount()` (`1736-1749`), not only TU children. Nested `asAST_DECL_FUNCTION` under `F` with `body.IsValid()` is pushed. `ActOnLambdaFromNode` sets that body.

First pass `asNEW(asCScriptFunction)(…, asFUNC_SCRIPT)` + `FillFunctionSignature` + `binds[]` keyed by **decl id** (`1793-1821`). Emit is a second pass (`1824-1835`). `FindFunc(decl)` (`321-328`) matches **decl id**, not first `"<lambda>"` name. Identity-safe if CALL `resolvedDecl` is the interned decl.

`FillFunctionSignature` (`1567-1636`) for this fixture should succeed: name `"<lambda>"`, return `int` (empty-key default), param `X:int`. It does **not** skip TRAIT_LAMBDA. `Commit` (`1676-1688`) currently publishes **all** artifact functions onto `module->globalFunctions` / `globalFunctionList` — both `F` and `"<lambda>"`. That is not the Build failure.

**What is missing is lowering**, not collection:

- No lambda-specific emit. The only funcdef-adjacent code is `LookupExistingFuncdef` / `FuncPtrHandleType` / `EmitFuncPtr` (`568-626`) used when a **DECL_REF of a FUNCTION** is materialized as a handle.
- Isolated tests that already execute (`CodeGenEmitsFuncdefCallAndLambda`, `CodeGenLambdaTeardownSurvivesEngineDestroy` in `AngelscriptNativeCanonicalASTCodeGenTests.cpp:773-863`) **`RegisterFuncdef("int Callback(int)")`** and assign the lambda to `Callback L`. Production fixture registers **nothing**.

---

## 5. Why CANONICAL `Build()` fail-closes today

Pipeline: `asCModule::Build` CANONICAL (`as_module.cpp:395-410`) parse → `SealCanonicalAST` → `asCBytecodeCodeGen::Generate`.

| Gate | Likely for this fixture? | File:line |
| --- | --- | --- |
| Parse | No. Same source parses in SemaAuthority. | |
| Seal diagnostics | No. Lambda does not `AddDiagnostic`. `SealCanonicalAST` only fail-closes if Sema diagnostics (`as_builder.cpp:684-692`). Verifier does **not** require CALL callee. | |
| Unresolved type / `FillFunctionSignature` | Unlikely. Empty return type became `int`. Params resolve. `asINVALID_DECLARATION` / `asINVALID_TYPE` (`1606-1628`) would fire for a **non-int** inferred lambda, not this one. | |
| **SEQUENCE prefix `DECL_REF` of the lambda** | **Yes — primary hole.** `EmitExpr(SEQUENCE)` evaluates every child (`504-509`). First child is `DECL_REF` of `asAST_DECL_FUNCTION` → `EmitDeclRef` (`644-652`) → `EmitFuncPtr` → `FuncPtrHandleType` → `LookupExistingFuncdef` walks `engine->funcDefs` / `registeredFuncDefs` (`568-592`) → miss → `FailAt(__LINE__, asNO_FUNCTION)` (`594-600`). Production fixture has **no** host funcdef. Isolated GREEN had `Callback`. | |
| Bare CALL missing bind | Secondary. `EmitCall` (`1137-1144`) `FindFunc(resolvedDecl)` then `FindSlot`; both miss → `asNO_MODULE`. Immediate-call `resolvedDecl` **is** the interned lambda, which **is** in `binds`. If the return is a **CALL**, emit would be `asBC_CALL` of that id (`1169-1174`) — the correct production lowering. | |
| Unsupported expr kind | If callee intern failed: `UNARY "("` → `FailAt asNOT_SUPPORTED` (`453-489`). Default unknown kind → `asINVALID_ARG` (`513-515`). | |
| `C3861 CastToObjectType` | Plugin **compile** of `FillFunctionSignature` (`1584`) after value-object registration. Blocks d95-impl UBT; it is **not** the lambda fixture’s runtime fail. Lambda is not a method. | |

Fail-closed is **wrong** for this fixture: it must execute `42` with publisher `CANONICAL_CODEGEN`. Do not invent a script `funcdef` so `EmitFuncPtr` can succeed. Skip discarded function `DECL_REF` in SEQUENCE **or** emit only the CALL (`asBC_CALL` of `FindFunc(resolvedDecl)`). Do not first-name-bind `"<lambda>"`.

---

## 6. Dialect constraints

- Tokenizer: `funcdef` and `is` stay commented (`as_tokendef.h:275`, `286`). No `@` handles in this fixture.
- Host `RegisterFuncdef` remains legal for **other** tests; this production method does **not** register one. Do not add it to GREEN the fixture.
- Mutable globals intern-then-reject is a different 9.5 method. Irrelevant here.
- `struct` VALUE vs `class` REF: not in this fixture.

---

## 7. Identity: interned decl, not first-name-bind

Snapshot identity **8/8** already includes `MultipleLambdasBindDistinctStableKeysNotZeroOrFirstName` (`AngelscriptStaticJITCanonicalASTIdentityTests.cpp:671-755`): two `$…` runtime lambdas bind **distinct** `TRAIT_LAMBDA` decls / `<lambda>(int)@offset` keys. Bind helper walks AST lambdas by param key + source offset (`AngelscriptStaticJITGenerationSnapshot.cpp:165-196`).

Sema dump identity: `MultipleLambdasKeepDistinctStableKeys` (`SemaAuthorityTests.cpp:222-278`).

Production CodeGen already keys `asSCodeGenFuncBind` by **decl id**. Immediate CALL already stores that id on `resolvedDecl`. **Do not** `ResolveCallee(owner, "<lambda>", args)` / `GetFunctionByIndex(0)` / first `name.Equals("<lambda>")`. Two lambdas share the name `"<lambda>"`; only `@offset` + decl id distinguish them.

This map does **not** close 9.5 (full-language CodeGen) or 13.3 (production identity from CodeGen Bytecode). Leave those `[ ]`.

---

## GREEN hint for exclusive `D-95-impl` (`as_bytecode_codegen.cpp` only)

Target: `return function(int X){ return X+1; }(41);` → execute 42.

1. Collect + bind the interned `TRAIT_LAMBDA` `asAST_DECL_FUNCTION` (already).
2. Emit `F`’s return as **`asBC_CALL` of that bind**, args reverse-formal (already in `EmitCall`).
3. Do **not** `EmitFuncPtr` / `LookupExistingFuncdef` for a discarded SEQUENCE `DECL_REF` of that lambda.
4. Do **not** `module->AddFuncDef()`, do **not** re-enable script `funcdef`.
5. Lambda body `return X+1` is ordinary PARAM ref + BINARY; `BindParameters` already slots `X`.
)
