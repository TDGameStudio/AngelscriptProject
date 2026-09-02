# Wave B exclusive UBT — Frontend CodeGen two fails — LANDED

Worktree: `D:\as-cta`. Change: `refactor-as-canonical-typed-ast-compiler`.
**Landed.** Frontend CanonicalAST **82/82** `wave-b-frontend-codegen`. Compiler CanonicalAST **242/242** `wave-b-frontend-canonical` (ProductionCodeGen **33/33** inside that prefix).
**Leave 13.2 / 9.5 `[ ]`.** Do not archive. Do not commit unless asked.

## Why this is next (not leftover intern, not 13.2)

Nested extract intern (`InternParsedChildStmt` + If stub fill + Switch no `ClearStmtChildren` + ParseCase ActOn) is already GREEN:

| Prefix | Result | Report |
| --- | --- | --- |
| SemaAuthority | **194/194** | `Saved\Tests\wave-b-nested-sema4\20260822_115816_593_dd3a0d6c` |
| Compiler CanonicalAST | **242/242** | `Saved\Tests\wave-b-nested-canonical2\20260822_120056_569_345b5dd4` |
| Frontend CanonicalAST | **80/82** | `Saved\Tests\wave-b-nested-frontend\20260822_120140_166_3bdea91a` |

The empty-TU Generate split (`module==0 && !hasFunctionLike` → 0; skip `AllocateGlobalProperty` when `defaultArg` empty) restored:

- isolated `Generate(nullptr)` empty TU
- `CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed` (defaultArg from Sema-eval)
- `CanonicalEnumOnlyBuildInstallsOrFailsClosed` (ENUM not in `CanonicalDeclIsSupportedForCodeGen`)
- `CodeGenRejectsUnsealedAstAndAcceptsSealed`

and broke two Frontend fixtures that share the same `Generate()` global/commit path.

Fixing them is **not** 13.2 (no Sema environment) and **not** 9.5 (not language coverage). It unblocks nested-extract verification.

## Already-red tests (do not add a third fixture unless both stay ambiguous)

Tests already fail. This is TDD: implement against existing RED, do not rewrite expectations.

### 1. `CodeGenEmitsGlobalIntReadWrite`

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTests.cpp:682`

Source (parse → Seal → isolated `Generate`):

```text
int G; int SetAndGet(int X) { G = X; return G; }
```

Fail: Generate `!= 0`, message `global int read/write should lower` (line 691).

Cause: `as_bytecode_codegen.cpp:2784-2787` skips every VAR with empty `defaultArg`. Mutable `int G` has no initializer, so CodeGen never `AllocateGlobalProperty`. The function then cannot lower `G = X` / `return G`.

This is **not** the production F2 `const int G = 41` path. F2 has Sema-eval `defaultArg`.

### 2. `CodeGenGlobalOnlyDeclDoesNotLeavePartialGlobals`

File: `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTCodeGenTransactionTests.cpp:376`

Handmade: `ActOnVarDecl(Tu, "G", IntType)` — empty `defaultArg`, **no functions**. Expect Generate `== 0`, Engine/module tables unchanged, publisher stays `asBYTECODE_PUBLISHER_NONE`.

Fail: `global-only: publisher before=0 after=2` (helper line 151) + `empty functionDecls must not AllocateGlobalProperty or set publisher` (line 397).

Cause: skipping allocate is not enough. `Generate` still always calls `artifact.Commit(module)` (`as_bytecode_codegen.cpp:3019`). `Commit` **always** `SetLastBytecodePublisher(asBYTECODE_PUBLISHER_CANONICAL_CODEGEN)` (`:2673`) even when `functions` is empty.

## Contract (do not collapse these four)

| Case | Functions | Global `defaultArg` | Isolated `Generate` | Production CANONICAL `Build` |
| --- | --- | --- | --- | --- |
| Empty TU / `module==0`, no function-like | no | n/a | return 0, no publisher | n/a |
| Handmade `int G;` no functions | no | empty | return 0, **no allocate, no `Commit`** | n/a |
| `const int G = 41` | no | `"41"` (Sema-eval) | n/a | **install G==41** or fail-closed; success publisher `CANONICAL_CODEGEN` |
| `enum EProd { Value = 41 }` only | no | n/a | n/a | fail-closed `asNOT_SUPPORTED` (ENUM excluded) |
| `int G;` + `SetAndGet` | yes | empty | **allocate G**, emit, `Commit` | allocate + emit |

Do **not**:

- skip every empty-`defaultArg` VAR (breaks SetAndGet)
- skip `Commit` whenever `functionDecls` is empty (breaks production const-global-only install publisher)
- make enum-only Build succeed
- implement CANONICAL `CompileFunction`
- check 13.2 / 9.5

## Chosen implementation

File: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_codegen.cpp` `Generate()`.

Keep the existing `module==0` gate (`:2718-2727`). Keep `CanonicalDeclIsSupportedForCodeGen` fail-closed for ENUM.

Replace the global loop skip:

```cpp
// WRONG (current)
if( child->defaultArg.GetLength() == 0 )
{
	continue;
}
```

with:

```cpp
const bool hasInitText = child->defaultArg.GetLength() != 0;
if( functionDecls.GetLength() == 0 && !hasInitText )
{
	continue;
}
```

Keep `strtoll` fail-closed only when `hasInitText` and integer (already gated by `child->defaultArg.GetLength()` at `:2801`).

After imports + function emission, **before** `artifact.Commit`:

```cpp
if( functionDecls.GetLength() == 0
	&& globals.GetLength() == 0
	&& binds.GetLength() == 0 )
{
	return asAST_VERIFY_OK;
}
const int commit = artifact.Commit(module);
```

Meaning:

- handmade uninit global-only → no allocate → `globals` empty → no Commit → publisher stays 0
- production `const int G = 41` → allocate into `globals` → Commit → publisher 2, G==41
- `int G` + functions → allocate even with empty defaultArg → emit → Commit
- enum-only never reaches this (unsupported kind)

Do not change `Commit` itself to skip publisher when functions empty: production const-global-only **wants** publisher 2 after a successful install.

## Must prove (GREEN)

1. Frontend CanonicalAST **82/82** (both named methods PASS).
2. Compiler CanonicalAST still **242/242**, especially:
   - `CanonicalConstGlobalOnlyBuildInstallsOrFailsClosed`
   - `CanonicalEnumOnlyBuildInstallsOrFailsClosed`
3. ProductionCodeGen still **33/33** (F2 globals with defaultArg still install).
4. SemaAuthority still **194/194** (no Sema edit required; run only if you touched Sema by mistake).
5. **Did not check 13.2 / 9.5.**

## Verification (from `D:\as-cta`, exclusive UBT, `-NoXGE`)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -NoXGE -Label wave-b-frontend-codegen
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label wave-b-frontend-codegen -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST" -Label wave-b-frontend-canonical -TimeoutMs 600000
```

`RunTests.ps1` does not UBT. Always `RunBuild.ps1` first. Do not run tests against a failed build.

If Frontend is GREEN and CanonicalAST is not run yet, do not claim nested-extract verification complete.

## Must not

- Second UBT in `D:\as-cta`
- Wave E–G, default CANONICAL, CANONICAL `CompileFunction`
- Script `funcdef` / `@` / `is`
- Re-enable mutable-global **language** (intern-then-reject stays; allocating an uninitialized `int G` for CodeGen slots is not that)
- Clang/LLVM link
- `NotifySema` for nested statements
- Checking 13.2 / 9.5 / 13.3 / 10.2 from prefix greens
