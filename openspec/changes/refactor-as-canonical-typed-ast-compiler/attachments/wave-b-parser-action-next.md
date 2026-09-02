# Wave B next Parser Sema actions (B-parser-next)

> **For later exclusive-UBT workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development. Add the failing SemaAuthority methods first. `RunBuild` then the SemaAuthority prefix **before** filling `as_parser.cpp` / `as_sema*`. Do **not** check `tasks.md` 13.2 / 5.9 / 4.2.

**Goal:** Exact TDD map for the next exclusive-UBT Wave B Parser-action slice **after** class/method/body land. Intern namespace / enum / interface / mixin-function declarations during parse (incomplete syntax must not drop them), then replace remaining `WalkOne(asCScriptNode)` **lookup authority** with a first-class Sema scope/symbol table. This is **not** Sema environment close (13.2) and **not** production `Build()` routing.

**Prerequisite (do not redo; do not start this UBT slice until green):**

| TEST_METHOD | File |
| --- | --- |
| `ParserActOnClassAndMethodDeclBeforeMemberBodyFails` | `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| `ParserActOnClassAndMethodDoesNotDuplicateOnSuccessfulParse` | same |
| `ParserActOnBodyStatementBeforeBodyParseFails` | same |

If those three are still red, finish **B-parser-class-method-body** first (`attachments/async-work.md` §6).

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode
  → incremental NotifySema / ActOn
        globals after name+params
        class after identifier + decl-context push
        methods after name+params
        local snDeclaration ActOn before a later body syntax error
        (do not WalkOne snReturn incrementally — ActOnReturnStmt steals the function body)
  → remaining forms still WalkOne of a complete parser node
        namespace / enum / interface / mixin / import / typedef
  → asCBuilder / asCCompiler                      (production Bytecode)
  → isolated asCBytecodeCodeGen::Generate()       (test-only)
```

LLVM/Clang is a **shape reference only** (`attachments/llvm-ast-architecture.md`). Do not link Clang/LLVM.

Already true after class/method/body (reuse, do not reimplement):

- `asCSema::PushDeclContext` / `PopDeclContext` / `CurrentDeclContext` / `NoteActedDecl` / `lastActedDecl`
- Parser RAII `asSDeclContextScope` + `PushLastActed()` in `as_parser.cpp`
- `ParseFunction(..., notifySemaAfterParams=true)` ActOn after name+params for globals **and** methods
- `FindExistingFunctionLike` matches name + param types + const trait
- `FindExistingNamedDecl` reuses Class / Var
- `ParseScript(!inBlock)` still `NotifySema`s completed top-level nodes; `ParseScript(true)` (namespace body) does **not**
- Mixin / local still `ParseFunction(false, false)` so they skip the name+params action

---

## Header (this attachment)

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-21 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-parser-next** (`attachments/async-work.md` §5) |
| Mode now | **Attachment only.** Do not edit fork sources. Do not run UBT / `RunBuild` / `RunTests`. Do not mark `tasks.md`. Do not commit. Do not archive. |
| Mode later | Exclusive UBT package **B-parser-next**: SemaAuthority TDD, then `as_parser.cpp` + `as_sema*`. **Do not mark 13.2.** |
| UBT mutex | One UBT user in `D:\as-cta`. If `UE4Editor` / `MSBuild` / `UnrealBuildTool` / `link` are live, wait. `-NoXGE`. |
| Order | namespace → enum → interface → mixin function → first-class Sema scope/symbol table |

虚标 = checking a task whose spec meaning is unmet. Parser actions for more decl forms are **not** 13.2. Production Bytecode is still `asCCompiler`. `Ready()` is false. Default is LEGACY.

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr` (not `null`); mixin **functions**, not mixin classes; mutable script globals forbidden (`const` only); `asEP_REQUIRE_ENUM_SCOPE=1` so enum values are `ETeam::Red`; host `RegisterFuncdef` / `RegisterEnum` allowed; source spelling `float` stays `float`.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces, indented with surrounding C++ (`Documents/Rules/ASInlineFormattingRule.md`).
- TDD per form. SemaAuthority prefix first. After all forms green, Compiler CanonicalAST prefix. **Never All.** Never production `Build()` routing. Never flip `Ready()` / default CANONICAL.
- **Hard no:** CALL-without-callee as a seal / verifier firewall. `asCASTVerify` must still succeed on unsealed graphs (`Seal()` needs that). Wave C 2.4 / 2.6 / 2.8 / 13.4 / 13.5 stay closed. Do not invent stmt-level cleanup-plan POD fields.
- Dump printer (`as_ast_dump.cpp`) **not** required for this slice. Reuse `kind=` / `name=` / `key=` / `quals=` / `callee=`. Do not add `scope=`.
- Implementer files: `as_parser.cpp`, `as_sema.h`, `as_sema.cpp`, `as_sema_decl.cpp`, `as_sema_expr.cpp`, SemaAuthority tests. Optional new `as_sema_scope.cpp` **only** if `as_sema.cpp` would bloat — then also `Plugins/Angelscript/Standalone/CMakeLists.txt` and `AngelscriptStandaloneArchitectureTests.cpp`. Prefer keeping the table on `asCSema` in `as_sema.h` / `as_sema.cpp`.
- Do **not** reuse legacy `as_symboltable.h` / `as_variablescope.h` (`asCCompiler` / bytecode load). Those are not the canonical Sema environment.
- Do not edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, `as_ast_verifier.cpp`, or `as_bytecode_codegen.cpp`.
- After these tests go green, **13.2 / 5.9 / 4.2 stay `[ ]`**. Record evidence in `attachments/wave-b-results.md` only if an implementer later runs tests (this attachment session does not).

---

## Dump / Sema surface this slice uses (already printed)

- DECL: `kind=Namespace` / `Class` / `Interface` / `Enum` / `Function` / `Method` / `Mixin` / `Var` / `Param` with `name=` `parent=` `key=` `quals=` `traits=`.
- Function-like keys: `FinishDecl` qualifies with non-TU parent (`Game::F(int)`, `IProbe::F(int)`, `ETeam::Red`). TU is **not** a lexical prefix (`key=F(int)` not `Module::F(int)`).
- EXPR Call: `callee=` / `nargs=` / `args=` / optional `route=import` / `receiver=` (already a dump field; do not restyle).
- `asEP_REQUIRE_ENUM_SCOPE=1` is already set in `FNativeTestEngine`.

Parser traps that make the RED honest:

- `ParseScript(true)` (namespace body) skips `NotifySema(decl)`.
- `ParseScript(!inBlock)` skips `NotifySema` when `isSyntaxError`.
- Incomplete inner syntax therefore only intern if the inner `Parse*` calls Sema **before** the failing token (class/method/global already do this; namespace/enum/interface/mixin do not).
- `ParseMixin` / `ParseLocal` call `ParseFunction(false, false)` so name+params ActOn is skipped; mixin token is prepended **after** `ParseFunction` returns, so a naive `notifySemaAfterParams=true` intern `MixHelper` as `kind=Function`.

---

## Exclusive-UBT order (TDD)

One form at a time. For each form: add the failing `TEST_METHOD`s → `RunBuild -NoXGE` → SemaAuthority prefix RED → implement that form → SemaAuthority prefix green → next form. After mixin greens, do the scope-table methods the same way. Then CanonicalAST prefix. Never All.

Shared test skeleton (every Parser-action method below): `FNativeTestEngine` + `ON_SCOPE_EXIT { Engine.Destroy(); }` + `CreateBuilderModule` + `Builder.silent = true` + `Parser.SetSema` + **no** `Module->Build()`. Complete-parse methods `Seal()`. Incomplete-parse methods assert `ParseResult < 0` and dump **without** requiring `Seal()` success.

---

### 1. Namespace

Implementer may edit: `as_parser.cpp` `ParseNamespace` (ActOn after identifier, `asSDeclContextScope::PushLastActed`, pop on leave). `as_sema_decl.cpp` `FindExistingNamedDecl(..., asAST_DECL_NAMESPACE)` before `ActOnNamespaceDecl`; `NoteActedDecl` on the namespace. Reuse the class-slice decl-context stack. Do **not** intern inner functions by waiting for a complete `snNamespace` WalkOne.

#### 1.1 `ParserActOnNamespaceDeclBeforeInnerBodyFails`

| Field | Value |
| --- | --- |
| File | `D:\as-cta\Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\Compiler\CanonicalAST\AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	namespace Game
	{
		int F(int a)
		{
			return
	)AS");
```

**Why this fixture:** `ParseFunction` already ActOn after name+params. Inside `ParseNamespace` that runs **before** the namespace node is complete. `CurrentDeclContext()` is still TU unless `ParseNamespace` ActOn+push after `Game`. `ParseScript(true)` will not NotifySema the namespace. `isSyntaxError` will not NotifySema the completed `snNamespace`.

**Must appear:** `kind=Namespace name=Game`; `kind=Function name=F`; `key=Game::F(int)`; `kind=Param name=a`.

**Must not appear:** `key=F(int)` as the only `F` (TU function); intern `F` as `kind=Method`.

**Expected first RED:** dump is empty **or** `kind=Function name=F` with `key=F(int)` and no `kind=Namespace name=Game`. Code today: `ParseNamespace` builds identifiers then `ParseScript(true)` with no Sema push; `WalkOne` `snNamespace` has no `FindExistingNamedDecl`.

#### 1.2 `ParserActOnNamespaceDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	namespace Game
	{
		int F(int a)
		{
			return a;
		}
	}
	)AS");
```

**Must appear:** exactly one dump line containing `kind=Namespace name=Game`; exactly one `kind=Function name=F`; `key=Game::F(int)`.

**Must not appear:** two `kind=Namespace name=Game` (incremental ActOn plus later complete-node WalkOne).

**Expected first RED:** two Namespace `Game` lines because `WalkOne` `snNamespace` always `ActOnNamespaceDecl` with no reuse. Mirror class `FindExistingNamedDecl`.

#### 1.3 `ParserActOnNestedNamespaceDeclBeforeInnerBodyFails`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script (nested **blocks**, not `namespace Game::Inner` as the first fixture):

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	namespace Game
	{
		namespace Inner
		{
			int F(int a)
			{
				return
	)AS");
```

**Must appear:** `kind=Namespace name=Game`; `kind=Namespace name=Inner`; `key=Game::Inner::F(int)`; `kind=Param name=a`.

**Must not appear:** `key=F(int)` or `key=Inner::F(int)` without the `Game::` prefix as the only `F`.

**Expected first RED:** inner `ParseNamespace` is `ParseScript(true)` so it never NotifySema at the script loop; without identifier ActOn+push, `F` lands on TU or on `Game` if only the outer push exists. `WalkOne` of `namespace Game::Inner` (single node, two identifiers) is **not** this fixture — do not substitute the `::` chain to dodge the stack.

If the `Game::Inner` identifier-chain form is cheap after 1.1–1.3 green, the same keys are the oracle. Do not block the slice on the chain form.

---

### 2. Enum (script enum, not host `RegisterEnum`)

Host `RegisterEnum("ETeam")` is already SemaAuthority `EnumParamOnCompileSealPathInternsEnumKind`. Do **not** redo it. This form is **script** `enum ETeam { Red, Blue }`. `asEP_REQUIRE_ENUM_SCOPE=1` so values are `ETeam::Red`, never a bare `Red` at TU.

Implementer may edit: `ParseEnumeration` ActOn after the enum identifier, push enum as decl context, ActOn each enumerator identifier as a **const** `Var` under the enum (no new dump kind). `WalkOne` `snEnum` must `FindExistingNamedDecl(..., asAST_DECL_ENUM)` and intern enumerators with `FindExistingNamedDecl` for `Var`. `quals=1` (`asAST_QUAL_CONST`). Do not intern a writable global `Red`.

There is no `ActOnEnumConstant`. Use `ActOnVarDecl` with `InternPrimitive(ttInt, …)` and const quals. `FinishDecl` then yields `key=ETeam::Red`.

#### 2.1 `ParserActOnEnumDeclAndEnumeratorBeforeListCloseFails`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	enum ETeam
	{
		Red,
		Blue =
	)AS");
```

**Why this fixture:** parser accepts `Red`, then `Blue`, then `=` and fails on the missing enumerator expression / closing `}`. Identifier ActOn must have run before that. Enumerator ActOn must have run for `Red` (and may intern `Blue` without a value — either is fine if `Red` is present).

**Must appear:** `kind=Enum name=ETeam`; `kind=Var name=Red`; `key=ETeam::Red`; the `Red` DECL line `quals=1`.

**Must not appear:** `kind=Var name=Red` with `quals=0` as an accepted writable global; host type `ETeam` from `RegisterEnum`; dump-only `kind=Enum` without `Red`.

**Expected first RED:** empty dump. `ParseEnumeration` returns an error node; `ParseScript` skips NotifySema on `isSyntaxError`. `WalkOne` `snEnum` intern only the enum name and **does not** walk enumerators (`as_sema_decl.cpp` `snEnum` arm).

#### 2.2 `ParserActOnEnumDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	enum ETeam
	{
		Red,
		Blue
	}

	int Entry()
	{
		return 0;
	}
	)AS");
```

**Must appear:** exactly one `kind=Enum name=ETeam`; exactly one `kind=Var name=Red`; `key=ETeam::Red`; `key=ETeam::Blue`.

**Must not appear:** two `kind=Enum name=ETeam`; `Entry` using unqualified `Red` (do not write that script).

**Expected first RED:** two Enum `ETeam` if identifier ActOn plus complete-node WalkOne both `ActOnEnumDecl` without reuse. Enumerator lines may still be missing until 2.1’s intern lands — keep both assertions.

Do not call `RegisterEnum` in either enum method.

---

### 3. Interface

Implementer may edit: `ParseInterface` ActOn after identifier + `PushLastActed`. `ParseInterfaceMethod` NotifySema after name+params **before** the required `;`. `WalkOne` `snInterface` must `FindExistingNamedDecl(..., asAST_DECL_INTERFACE)` and `NoteActedDecl`. Parent kind `INTERFACE` already routes `ActOnFunctionLike` to `ActOnMethodDecl`.

Do **not** write script `funcdef`. Interface methods are `;` signatures, not bodies.

#### 3.1 `ParserActOnInterfaceAndMethodDeclBeforeSignatureFails`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	interface IProbe
	{
		int F(int a)
	)AS");
```

**Why this fixture:** `ParseInterfaceMethod` parses type+name+params then errors on missing `;`. That is the method analogue of “after name+params, before body”.

**Must appear:** `kind=Interface name=IProbe`; `kind=Method name=F`; `key=IProbe::F(int)`; `kind=Param name=a`.

**Must not appear:** `key=F(int)` as a TU `Function`; `kind=Function name=F` as the only `F`; script `funcdef`.

**Expected first RED:** empty dump. `ParseInterface` does not NotifySema after the identifier; `ParseInterfaceMethod` has no NotifySema; `isSyntaxError` skips the completed-interface WalkOne.

#### 3.2 `ParserActOnInterfaceDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	interface IProbe
	{
		int F(int a);
	}
	)AS");
```

**Must appear:** exactly one `kind=Interface name=IProbe`; exactly one `kind=Method name=F`; `key=IProbe::F(int)`.

**Expected first RED:** two Interface `IProbe` and/or two Method `F` because `WalkOne` `snInterface` always `ActOnInterfaceDecl` with no reuse.

`bases=` / inheritance is **not** this slice (`RecordClassBases` may stay as WalkOne recovery).

---

### 4. Mixin **function** (not mixin class)

Implementer may edit: `ParseMixin`. The mixin token **must** be a child of the `snFunction` node **before** NotifySema so `ActOnFunctionLike` sees `ttMixin` / identifier `"mixin"` and calls `ActOnMixinDecl`. Then NotifySema after name+params, before the body. `ParseFunction(false, false)` today is the trap: it skips the action **and** the token is prepended only after the body parse returns.

Do **not** write `mixin class`. Do not treat mixin as a decl-context type like `class T` (it is a function-like; `PushLastActed` of the mixin **function** for the body is correct, same as global functions).

#### 4.1 `ParserActOnMixinFunctionDeclBeforeBodyFails`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` (no `Build()`, no `Seal()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	mixin int MixHelper(int a)
	{
		return
	)AS");
```

**Must appear:** `kind=Mixin name=MixHelper`; `key=MixHelper(int)`; `kind=Param name=a`.

**Must not appear:** `kind=Function name=MixHelper` as the only MixHelper (token missing at ActOn time); `mixin class`.

**Expected first RED:** empty dump (`notifySemaAfterParams=false`, incomplete body, TU NotifySema skipped). If someone only flips `notifySemaAfterParams` without prepending the mixin token first: `kind=Function name=MixHelper` `key=MixHelper(int)` — still RED for this method.

Keep existing `MixinFunctionKeepsMixinKindAndSignature` (`Build()` path). Do not change its `key=MixHelper(int)` contract.

#### 4.2 `ParserActOnMixinDoesNotDuplicateOnSuccessfulParse`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`) |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	mixin void MixHelper(int a)
	{
	}

	int Entry()
	{
		return 1;
	}
	)AS");
```

**Must appear:** exactly one `kind=Mixin name=MixHelper`; `key=MixHelper(int)`.

**Must not appear:** Mixin + Function both named `MixHelper` (first ActOn without token, second WalkOne with token).

**Expected first RED:** two MixHelper decls, or one Function plus one Mixin, because `FindExistingFunctionLike` will not match Function vs Mixin kind if the first intern was the wrong kind.

`ParseLocal` is **not** this slice.

---

### 5. First-class Sema scope / symbol table

Do **not** add more `WalkOne(asCScriptNode)` arms as the lookup authority. Parser actions intern; Sema owns scopes and symbols; `asCScriptNode` stays recovery / Builder comparison input.

API on `asCSema` (names may match exactly — tests call these):

```cpp
void InsertSymbol(asASTDeclId id); // called from ActOn* ; safe to no-op on invalid
asUINT LookupCandidates(const char* name, asCArray<asASTDeclId>& out) const;
```

Rules:

- Lookup walks the **decl-context stack** then parent decls to the TU. Collect **all** same-name function-likes in the **first** scope that has any match (inner name hides outer overloads; same-scope overloads are all returned).
- `InsertSymbol` on every successful `ActOnNamespaceDecl` / `ActOnClassDecl` / `ActOnEnumDecl` / `ActOnInterfaceDecl` / `ActOnFunctionDecl` / `ActOnMethodDecl` / `ActOnMixinDecl` / `ActOnVarDecl` / `ActOnParamDecl` (and ctor/dtor if already ActOn’d).
- `as_sema_expr.cpp` `FindNamedDecl` / `FindBestCallee` must query `LookupCandidates`, not a private walk of `asCScriptNode`. Linear `asCDecl::children` scan is allowed only as a temporary inside the table implementation, not as Parser-tree authority.
- Do not link Clang. Do not import `as_symboltable.h`.
- No new dump token.

Hand-built methods construct decls with `ActOn*` only — **zero** `asCScriptNode`. That is the architecture test.

#### 5.1 `SemaScopeLookupPrefersCurrentContextThenOuterAfterPop`

| Field | Value |
| --- | --- |
| Path | Hand-built `asCSema` (no Parser, no `Build()`) |

```cpp
asCASTContext Context;
asCSema Sema(ScriptEngine, Context);
const asASTDeclId tu = Sema.ActOnTranslationUnit("SemaScopePop");
const asCQualType intType = Context.InternPrimitive(ttInt, 0);
const asCSourceRange Range;
const asASTDeclId globalF = Sema.ActOnFunctionDecl(tu, "F", intType, Range);
const asASTDeclId game = Sema.ActOnNamespaceDecl(tu, "Game", Range);
Sema.PushDeclContext(game);
const asASTDeclId innerF = Sema.ActOnFunctionDecl(game, "F", intType, Range);
asCArray<asASTDeclId> innerHits;
ASSERT_THAT(AreEqual(1, (int)Sema.LookupCandidates("F", innerHits),
	TEXT("inner scope must see Game::F only")));
ASSERT_THAT(IsTrue(innerHits[0] == innerF, TEXT("current context wins")));
Sema.PopDeclContext();
asCArray<asASTDeclId> outerHits;
ASSERT_THAT(AreEqual(1, (int)Sema.LookupCandidates("F", outerHits),
	TEXT("after pop, TU F must be visible")));
ASSERT_THAT(IsTrue(outerHits[0] == globalF, TEXT("pop must not leak Game::F as first hit")));
```

**Expected first RED:** `LookupCandidates` is not a method (`as_sema.h` has no symbol table). Do not green this by walking `asCScriptNode`. A children-walk of `CurrentDeclContext()` that ignores `InsertSymbol` may accidentally pass 5.1 — 5.2 exists to stop “first child” lookup.

#### 5.2 `SemaScopeLookupReturnsBothOverloadCandidatesNotFirstName`

| Field | Value |
| --- | --- |
| Path | Hand-built `asCSema` (no Parser, no `Build()`) |

Two TU functions `F` with params `int` and `float` (source spelling `float`). `ActOnParamDecl` so `FinishDecl` keys are `F(int)` and `F(float)`.

**Must:** `LookupCandidates("F", out) == 2`; dump or `GetDecl(out[i])->stableKey` contains both `F(int)` and `F(float)` (order irrelevant).

**Must not:** return only the first interned `F`.

**Expected first RED:** API missing, or a `FindNamedDecl`-shaped helper that returns the first same-name child (`as_sema_expr.cpp` ~34–54).

#### 5.3 `SemaScopeLookupSelectsInnerNamespaceFunctionNotGlobal`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`). Unqualified call **inside** `Game`. Existing `NamespaceOverloadSelectsScopedFunctionNotGlobal` is CANONICAL `Build()` + **qualified** `Game::F(3)` — keep it; this method is Parser-action + table. |

Inline script:

```cpp
const std::string ScriptSource = ASTEST_AS_ANSI(R"AS(
	int F(int a)
	{
		return 1;
	}

	namespace Game
	{
		int F(int a)
		{
			return 2;
		}

		int Entry()
		{
			return F(3);
		}
	}
	)AS");
```

**Must appear:** `key=Game::F(int)`; `key=F(int)`; `callee=Game::F(int)` on Entry’s call.

**Must not appear:** `callee=F(int)` as Entry’s bind.

**Expected first RED (honest):** if complete-tree `WalkOne` of `snFunction` + `FindNamedDecl` already binds `Game::F` from `Game`’s children, this dump may go **green without a table**. That does **not** close 13.2 and does **not** skip 5.1 / 5.2 / 5.4. Still wire `FindBestCallee` to `LookupCandidates` so expression Sema stops being a private node walk. Record the dump result in `wave-b-results.md`; leave 13.2 `[ ]`.

#### 5.4 `SemaScopeLookupRequiresEnumScopeForEnumerator`

| Field | Value |
| --- | --- |
| Path | Parser `SetSema` + `Seal()` (no `Build()`). Script enum only. Do not `RegisterEnum`. Engine already has `asEP_REQUIRE_ENUM_SCOPE=1`. |

Inline script (qualified):

```cpp
const std::string QualifiedSource = ASTEST_AS_ANSI(R"AS(
	enum ETeam
	{
		Red,
		Blue
	}

	int Entry()
	{
		return ETeam::Red;
	}
	)AS");
```

Unqualified probe (same method, second parser/sema — must **not** bind a free `Red`):

```cpp
const std::string UnqualifiedSource = ASTEST_AS_ANSI(R"AS(
	enum ETeam
	{
		Red,
		Blue
	}

	int Entry()
	{
		return Red;
	}
	)AS");
```

**Must appear (qualified):** `kind=Enum name=ETeam`; `key=ETeam::Red`; a DeclRef/call/expr dump whose resolved key is `ETeam::Red` (DeclRef `callee=` may be empty — assert the DECL key **and** that the Entry body interned a ref to that decl, e.g. dump contains `ETeam::Red` on an EXPR line **or** `LookupCandidates` after parse is not how this is proven; prefer dump `key=ETeam::Red` plus Entry not empty of expr nodes). Practical oracle: dump contains `key=ETeam::Red` and an EXPR whose `callee=ETeam::Red` **or** DeclRef target is that decl. If DeclRef dump has no `callee=`, assert via `Sema.LookupCandidates` is the wrong tool for `ETeam::Red` (qualified). After parse, walk dump lines: `kind=Var name=Red` with `key=ETeam::Red`. For the Entry expression, `ResolveScopeOwner` + table must set `resolvedDecl`. If the dump grammar has no DeclRef callee, assert `Text.Contains(TEXT("key=ETeam::Red"))` **and** that unqualified (below) has no EXPR binding to `Red` as a TU name.

**Must not appear (unqualified):** successful bind of TU `Red` (`key=Red` as a free Var, or EXPR `callee=Red`). Empty `callee=` / diagnostic is allowed. Do not `Seal()`-require success on the unqualified script if Sema records `enum-scope-required` / similar; dump must not intern `Red` as a TU symbol.

**Expected first RED:** enumerators are not decls (`WalkOne` `snEnum` name-only), so `key=ETeam::Red` is missing; `ETeam::Red` cannot `FindDirectChildNamed`. Unqualified `Red` already misses today (no TU child `Red`) — that half may be green; the qualified half is the RED.

Do not write `is`, `@`, or `null`.

---

### Substitutions (do not invent fork-rejected tests)

| If blocked | Substitute |
| --- | --- |
| Script `funcdef` / `@` / `is` | Never. Host `RegisterFuncdef` is a different surface (already allowed; not this slice). |
| `mixin class` | Never. Mixin **function** only (`mixin int MixHelper`). |
| `namespace Game::Inner` chain | Nested **blocks** (method 1.3). Chain is optional extra, same keys. |
| Host `RegisterEnum` for 2.* / 5.4 | Never in those methods. Method 23 already covers host enum Engine kind. |
| `null` literal | `nullptr` only if a literal is required (these methods do not need it). |
| New dump `scope=` token | Do not add. Use `key=` / `callee=` / `LookupCandidates`. |
| 5.3 already green via WalkOne | Wire table anyway; do not check 13.2; proceed to 5.4. |
| New `as_sema_scope.cpp` | Allowed; then CMake + Standalone architecture file list. Prefer `as_sema.cpp`. |

---

## Verification commands (implementer later; this session does not run them)

Working directory **`D:\as-cta` only**. One UBT user. `-NoXGE`. Never All. Never production `Build()` routing.

RED (after adding the next form’s methods, before filling Sema/Parser):

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-parser-next-build -TimeoutMs 1800000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-next-red -TimeoutMs 600000
```

Expect the new methods red (or the hand-built methods failing to compile until `LookupCandidates` exists — add the methods only after the API is declared **or** accept a compile-RED on `as_sema.h` in the same TDD step: declare the empty API returning 0 **first** so tests compile and assert, then fill). Preferred TDD: declare `LookupCandidates` returning 0 in `as_sema.cpp` as a one-liner **with the 5.1 test in the same RED cycle**, then implement.

GREEN (after each form, and after the whole slice):

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-parser-next-green -TimeoutMs 600000
```

After **all** methods in this attachment are green, also Compiler CanonicalAST (never All):

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-parser-next-canonical -TimeoutMs 600000
```

Do not reopen Verifier. Do not require CALL-without-callee to fail `Seal()`. Do not run `RunTestSuite.ps1 -Suite All`.

---

## Architecture vs this slice — 13.2 cannot close

These methods, even all green, prove **more Parser Sema actions** and a Sema-owned lookup table for interned decls. They do not replace:

```text
Parser still builds asCScriptNode (recovery)
  → expression/call/lifetime still ActOnExprFromNode / ActOnStmtFromNode of parser nodes
  → import / typedef / script funcdef / lambda still WalkOne
  → production Bytecode from asCCompiler
  → Ready() false, default LEGACY, publisher COMPILER on Build()
```

13.2 close criteria (all must hold; **leave 13.2 `[ ]` after this slice**):

1. Parser calls Sema actions for the language (TU/namespace/class/method/function/body **and** remaining forms), not a post-parse WalkOne of a complete `asCScriptNode` tree as the semantic **authority**.
2. Sema owns scopes, symbols, overload **candidates**, conversions, call plans, lifetimes, control targets as interned facts.
3. Sealed dumps/views show those facts.
4. Production backends (`asCBytecodeCodeGen` on the `Build()` path, TypedASTJIT) consume the sealed graph and **do not rerun Sema**.
5. `asCScriptNode` may remain recovery / Builder comparison input.

After this slice (1) is still incomplete (import/typedef/lambda/expr bodies). (2) has a scope table and more interned decls, not conversions/call-plans/lifetimes as backend inputs. (4) is false: production Bytecode is `asCCompiler`. Dumps with `key=Game::F(int)` / `key=ETeam::Red` are still shadow facts until Wave D `Build()` consumes them.

What still cannot close 13.2 after namespace/enum/interface/mixin + table land:

| Gap | Why still open |
| --- | --- |
| Production consumption | `asCModule::Build()` still publishes `asCCompiler`. Isolated `Generate()` is test-only. |
| Expression Sema | `ActOnExprFromNode` still walks `asCScriptNode`. Table lookup does not freeze conversion/call/lifetime plans for backends. |
| Overload **candidate sets** as sealed facts | `LookupCandidates` is a Sema API; dumps still show the **selected** `callee=`, not the candidate list. Ambiguity/hidden/native ABI remain later dump rows. |
| Import / typedef / lambda / local | Still complete-node WalkOne (and script `funcdef` is fork-rejected). |
| Control phases / cleanup plans | Continue/break targets exist as dumps; for-init/cond/incr phases and stmt cleanup-plan PODs are not this slice. |
| 4.6 / 13.3 / 5.9 | No builder-vs-canonical fail-closed publish; param quals/ABI still missing; complete-language Sema unmet. |
| Wave D/G | Do not route `Build()`, do not set `Ready()` true, do not default CANONICAL. |

Next exclusive UBT **after** this package (not this attachment): either remaining Parser actions (import/typedef) **or** queued `attachments/wave-d-r09-task2plus.md` (stop before production `Build()`). Do not start Wave E/F/G.

---

## Checkbox discipline

| After this slice is green | Box |
| --- | --- |
| 13.2 Sema environment | stays `[ ]` |
| 5.9 complete-language Sema | stays `[ ]` |
| 4.2 Parser Sema-action entry points | stays `[ ]` (more forms, not the language) |
| 4.3 / 4.4 / 4.5 / 4.6 / 5.2–5.8 / 13.3 | stay `[ ]` |
| 2.4 / 2.6 / 2.8 / 13.4 / 13.5 | stay `[x]` — do not reopen |
| 13.6 / 9.1 / section 10 | stay `[ ]` — do not route `Build()` |

Implementer evidence (not this session): append to `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-b-results.md` with prefix, label, report path, pass/fail. Do not rewrite remaining `tasks.md` boxes down to match Parser greens.

---

## File map (exact paths under `D:\as-cta`)

| Path | Role in this slice |
| --- | --- |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-b-parser-action-next.md` | This map |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\async-work.md` | Package definition; 13.2 must stay `[ ]` |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-b-sema-remainder.md` | Style/oracle for dump TDD; remainder dumps already landed |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\llvm-ast-architecture.md` | Clang shape reference; no link |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\attachments\wave-b-results.md` | Implementer-only later evidence |
| `D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler\tasks.md` | 4.2 / 5.9 / 13.2 stay `[ ]` |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptTest\AngelScriptSDK\Compiler\CanonicalAST\AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` | Add methods 1.1–5.4 after the class/method/body methods |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_parser.cpp` | `ParseNamespace` / `ParseEnumeration` / `ParseInterface` / `ParseInterfaceMethod` / `ParseMixin`; reuse `asSDeclContextScope` |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_parser.h` | Only if mixin/enum helpers need a flag; do not new virtuals |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema.h` | `LookupCandidates` / `InsertSymbol`; no Unreal types |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema.cpp` | Scope stack table implementation (preferred home) |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema_decl.cpp` | `FindExistingNamedDecl` for Namespace/Enum/Interface; enumerator `Var`; `InsertSymbol` from ActOn; **do not grow WalkOne as authority** |
| `D:\as-cta\Plugins\Angelscript\Source\AngelscriptRuntime\ThirdParty\angelscript\source\as_sema_expr.cpp` | `FindNamedDecl` / `FindBestCallee` → `LookupCandidates` |
| `D:\as-cta\Plugins\Angelscript\Standalone\CMakeLists.txt` | Only if a new `as_sema_scope.cpp` is added |
| `D:\as-cta\Plugins\Angelscript\Standalone\Tests\AngelscriptStandaloneArchitectureTests.cpp` | Same — file list must mention any new fork `.cpp` |

Do not touch: `as_compiler.cpp` emit, `as_module.cpp` `Build()`, `as_bytecode_codegen.cpp`, `as_ast_verifier.cpp`, `as_ast_dump.cpp` (unless a test is blocked on a missing existing token — it should not be), `Core/angelscript.h`, `as_symboltable.h`, `as_variablescope.h`.

---

## What this attachment did **not** do

- Did not implement fork / test sources.
- Did not run UBT / `RunBuild` / `RunTests`.
- Did not mark any `tasks.md` box (including 13.2).
- Did not commit or archive.
- Did not recommend checking 13.2 after these greens.
- Did not route production `Build()` or flip `Ready()` / default CANONICAL.
