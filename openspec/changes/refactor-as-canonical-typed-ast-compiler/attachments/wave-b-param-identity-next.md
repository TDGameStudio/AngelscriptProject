# Wave B exclusive UBT — 4.2 param intern identity (B-param-identity)

> **For the exclusive-UBT worker:** REQUIRED SUB-SKILLS: `superpowers:systematic-debugging` first (unexpected RED after intern), then `superpowers:test-driven-development`. Do **not** check `tasks.md` 4.2 / 13.2 / 13.3 / 9.5.

**Goal:** Keep Clang intern-after-name + incremental `ActOnParsedParam`. Make constructor overload selection and incomplete-later-function identity hold on the real Parser/Sema path. SemaAuthority must return to all-green without dropping the three param tests.

**Architecture today (do not contradict):**

```text
legacy Parser → asCScriptNode (recovery)
  → ParseFunction NotifySema after name (notifySemaAfterParams=true, flag name stale)
  → ParseParameterList ActOnParsedParam after each complete param
  → FindExistingFunctionLike: no snParameterList → invalid  (THIS is the live bug)
  → WalkOne leftover extract still fills complete functions
  → CANONICAL Build fail-closes on Sema diagnostics
  → LEGACY still asCCompiler
```

LLVM/Clang is a **shape reference only**. Do not link Clang/LLVM.

---

## Header

| Field | Value |
| --- | --- |
| Worktree | `D:\as-cta` (junction → `.worktrees\refactor-as-canonical-typed-ast-compiler`) |
| Date | 2026-08-22 |
| Change | `refactor-as-canonical-typed-ast-compiler` |
| Package | **B-param-identity** (`attachments/async-work.md` §7) |
| Mode | Exclusive UBT. TDD. One UBT user. |
| Evidence | SemaAuthority **200/202** `wave-b-param-sema` `D:\as-cta\Saved\Tests\wave-b-param-sema\20260822_124316_520_7b2d9aeb` |
| Do not mark | 4.2 / 13.2 / 13.3 / 5.4 / 5.6 / 9.5 |

---

## Global constraints

- Fork dialect: no script `funcdef` / `@` / `is`; `nullptr`=`ttNull`; mixin **functions**; mutable script globals intern then reject; host `RegisterFuncdef` legal.
- Inline AngelScript: `ASTEST_AS_ANSI(R"AS( ... )AS")`, Allman braces (`Documents/Rules/ASInlineFormattingRule.md`).
- Commands only from `D:\as-cta`: `Tools\RunBuild.ps1` / `RunTests.ps1` / `RunTestSuite.ps1`. Always `-NoXGE`. `RunTests.ps1` does not UBT.
- **Hard no:** CALL-without-callee; default CANONICAL; CANONICAL CompileFunction; second UBT; archive; commit unless asked; Unreal types in fork frontend files.
- Implementer files: `as_sema_decl.cpp` (`FindExistingFunctionLike` / `ActOnFunctionLike` / WalkOne `snFunction`), `as_parser.cpp` only if NotifySema timing must move, SemaAuthority tests. Prefer identity helper over reverting intern-after-name.
- Do **not** edit `as_compiler.cpp` production emit, `as_module.cpp` `Build()` routing, `as_ast_verifier.cpp` firewall, or `as_bytecode_codegen.cpp` unless a ctor Build failure is proven to be CodeGen — then stop and record; ctor fail is expected to be Sema diagnostics / duplicate intern.

---

## Chosen identity policy (do not revert intern-after-name)

Clang-shaped 4.2:

1. Intern the function-like **after the name**, before the parameter list closes.
2. Intern each **complete** param via `ActOnStartParamDecl` / `ActOnParsedParam`.
3. Incomplete `int F(int A, float` keeps Function F + Param A.
4. A node **without** `snParameterList` must reuse the **in-flight** decl of **this** identifier (same parent + name + kind + source range of the name token / `lastActedDecl` if it is that in-flight function-like).
5. A node without `snParameterList` must **not** match a **completed different overload** (existing `F()` vs later `F(int)` after-name intern).
6. Incomplete later `int Second(` **may** intern as a distinct 0-param Function. It must not steal First's body or params. Update the old `!name=Second` assert if the dump honestly contains Second.

Rejected:

- Revert `FindExistingFunctionLike` no-list → invalid without a replacement in-flight match (reopens `F()` collapsing onto `F(int)`).
- Delay NotifySema until `)` (drops `ParserActOnParamBeforeParameterListCloseFails`).

---

## RED evidence (already written; do not add a stub-only cycle)

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

| TEST_METHOD | Live failure | Required after fix |
| --- | --- | --- |
| `ConstructorOverloadsSelectExactCtorNotFirstName` | `Build()` != 0 at line 240. Log: `constructor module must compile` | Build==0. `key=T::T()` / `key=T::T(int)` / `key=T::~T()` / `callee=T::T(int)` / not `callee=T::T()` |
| `ParserSemaActionsRecordFirstFunctionWhenLaterSyntaxFails` | Shared DumpMsg. Likely `!name=Second` after intern-after-name | Parse fails. `kind=Function name=First`. If `name=Second` exists: distinct decl, 0 params, does not own First's body. **Do not require Second absent** if intern-after-name created it |
| `SemaStartParamDeclActionRecordsParamWithoutScriptNode` | PASS — keep | one Param A, same id on second ActOn, `key=F(int)` |
| `ParserActOnParamBeforeParameterListCloseFails` | PASS — keep | parse < 0, Function F + Param A |
| `ParserActOnParamDoesNotDuplicateOnSuccessfulParse` | PASS — keep | one Param A |
| `ParserActOnFunctionDeclDoesNotDuplicateOnSuccessfulParse` | must stay PASS | one Function F |

If you change Fail B asserts, keep a lock that First is interned **during parse** (SetSema path, no `Build()`).

---

## Step 1 — systematic-debug (no guess edit)

1. Read `FindExistingFunctionLike` (`as_sema_decl.cpp` ~950), `ActOnFunctionLike` (~807), WalkOne `snFunction` (~1330), `ParseFunction` NotifySema (~3680), `ActOnParsedParam` (~592), `ActOnStartConstructorDecl` (`as_sema.cpp` ~347).
2. Reproduce mentally:
   - ctor: after-name intern `T()` then after-name intern another `T()` then attach `int a`.
   - First/Second: after-name intern First (0-param), complete body; after-name intern Second; param list fails.
3. If helpful, temporarily dump `asCASTDump` + `Sema.diagnostics` inside the ctor test around `Build()` — **remove the temporary before finish**, or convert it into a durable assertion of empty diagnostics.
4. Root cause must name **which decl ids** exist at Seal/Build: two `T()` 0-arg, or `T(int)` attached to the class, or InsertSymbol collapse.

Do not “fix” by making CANONICAL skip Seal diagnostics.

---

## Step 2 — failing assert adjustment only if policy requires it

If dump contains First **and** Second:

```cpp
ASSERT_THAT(IsTrue(Text.Contains(TEXT("kind=Function name=First")), *DumpMsg));
ASSERT_THAT(IsTrue(!Text.Contains(TEXT("name=Second")), *DumpMsg)); // stale vs intern-after-name
```

Replace the second assert with: Second, if present, is a separate Function (count `kind=Function name=First` == 1; First dump line has a body/return; Second has no Param children / no stolen `return 1` body). Keep parse result < 0.

Do **not** weaken `ConstructorOverloadsSelectExactCtorNotFirstName`.

---

## Step 3 — minimal FindExisting in-flight match

Suggested shape (implement against the tests, not this sketch as copy-paste gospel):

```cpp
static asASTDeclId FindExistingFunctionLike(...)
{
    // name / lambda / parent as today
    const bool hasParamList = FirstChildOfType(node, snParameterList) != 0;
    if( !hasParamList )
    {
        // In-flight intern-after-name: reuse lastActed / same name-token range.
        // Do NOT match a completed different overload by name alone.
        if( const asCDecl* acted = sema->GetContext().GetDecl(sema->LastActedDecl()) )
        {
            if( acted->parent == parent && acted->name.Equals(name)
                && /* function-like kind */ && acted->range.begin.offset == nameTokenOffset )
            {
                return acted->id;
            }
        }
        return asASTDeclId();
    }
    // existing signature match (param count + types + const trait)
}
```

`ActOnStartConstructorDecl` must keep creating a **new** ctor when the in-flight match is a **different** name-token range (`T()` vs `T(int)`).

`FinishDecl` / `InsertSymbol` must not collapse two constructors by bare name.

WalkOne `snFunction` must FindExisting the after-name decl once `snParameterList` exists (param count + types), then `AttachParsedFunctionBody` / `WalkParameterList` without duplicating params (`ActOnStartParamDecl` already FindExisting by name).

---

## Step 4 — verify

From `D:\as-cta` only:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-param2
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label wave-b-param-sema2 -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-param-canonical -TimeoutMs 600000
```

If CanonicalAST is green, run Compiler prefix:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler" -Label wave-b-param-compiler -TimeoutMs 600000
```

Expected: SemaAuthority all PASS (202/202 or live total). CanonicalAST all PASS. Compiler all PASS. **Did not check 4.2 / 13.2 / 13.3 / 9.5.**

Record evidence in `attachments/wave-b-results.md` (append a short param-identity section). Patch `tasks.md` 4.2 **progress note only**. Leave the box `[ ]`.

---

## Files

- Modify: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema_decl.cpp`
- Maybe: `as_sema.cpp` `ActOnStartConstructorDecl` / `InsertSymbol` only if duplicate-by-name is proven
- Maybe: `as_parser.cpp` only if NotifySema must also fire for methods when `notifySemaAfterParams` default is wrong — default is already `true`
- Modify: `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` Fail B asserts only if intern-after-name interned Second
- Do not: `as_compiler.cpp`, `as_module.cpp` Build routing, verifier firewall, CodeGen Generate, `tasks.md` checkbox

---

## Done means

- Root cause named (decl ids + why Build failed / why First assert failed).
- Three param tests still PASS.
- Ctor compile→seal selects `T::T(int)`.
- Incomplete later function does not drop First.
- Prefix greens recorded. Boxes stay `[ ]`.
