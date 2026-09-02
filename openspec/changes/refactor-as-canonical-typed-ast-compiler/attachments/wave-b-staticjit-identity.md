# Wave B — StaticJIT FunctionKey↔AST identity bind (R03 map)

Package: **B-jit-identity**. Implementer now: `attachments/wave-b-jit-identity-float.md`.
Wave B dump / SemaAuthority identity fixtures remain a separate package. This file maps the StaticJIT generation bind. **Reject ambiguous**, never bind-first.

Review: `reviews/implementation-review-2026-08-21.md` **R03**.
Tasks that must stay `[ ]` until the TDD below is green: **13.3**, **7.2**, **7.4**.

---

## 1. Bind site (exact function + lines)

| Item | Current evidence |
| --- | --- |
| Function | `BuildAngelscriptStaticJITGenerationSnapshot` |
| File | `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp` |
| Signature | starts at **967** |
| FunctionKey build | **1117–1137** (`FAngelscriptCacheStableSymbolIdentity::TryBuildFunctionKey`) |
| AST bind loop | **1139–1225** (review cited ~1139–1157 as name-first; confirm current lines) |
| Result field | `FAngelscriptStaticJITGenerationFunction::CanonicalFunctionDeclValue` (+ `SealedAST`) in `AngelscriptStaticJITGenerationSnapshot.h` **43–65** |

Related consumer (not the snapshot bind, but the mis-bind amplifier):

| Item | Current evidence |
| --- | --- |
| Helper | `FindFunctionDecl` in `TypedASTJIT/AngelscriptTypedASTJITCanonical.cpp` **141–175** |
| Name-only API | `FindAngelscriptTypedASTJITCanonicalFunctionDecl` **822–828** |
| Eligibility use | `EvaluateAngelscriptTypedASTJITEligibilityFromCanonical` **849–852** calls `FindFunctionDecl(Context, CanonicalFunctionDecl, nullptr)` |

When `CanonicalFunctionDecl` is invalid and `Name` is `nullptr`, `FindFunctionDecl` returns the **first** `asAST_DECL_FUNCTION` / `asAST_DECL_METHOD` in the sealed context (**164–172**). That is still a first-same-kind fallback even if the snapshot left `CanonicalFunctionDeclValue == 0`.

---

## 2. What is compared today (2026-08-21 update)

`BindCanonicalFunctionDeclValue` now builds `BuildRuntimeAstIdentityKey(Function)` and binds iff exactly one AST decl of function/method/ctor/dtor/mixin/import has `Decl->stableKey.Equals(Expected)`.

Expected key shape: optional `objectType::` or `namespace::` + name + `(` + per-param Runtime primitive/object name + `)`.

`PrimitiveAstTypeKey` currently maps `ttInt`→`int`, `ttFloat|ttDouble`→`float`, `ttBool`→`bool`, `ttVoid`→`void`, else `""`.

**Live hole:** dialect script `float` is Runtime `ttFloat64`. Expected becomes `F()` while AST `FinishDecl` is `F(float)` → unique float DeclId 0. Namespace twins and DeclId-0 eligibility are GREEN.

Eligibility `FindFunctionDecl(Context, DeclId, nullptr)` returns nullptr when DeclId is invalid (first-function / whole-module walk removed). Name-only `FindAngelscriptTypedASTJITCanonicalFunctionDecl` still exists for unique names; do not use it as the snapshot bind.

### Runtime FunctionKey (for contrast)

`TryBuildFunctionKey` (`AngelscriptCacheStableSymbolIdentity.cpp` **167+**) hashes module + invocation kind + namespace + owner TypeKey + canonical declaration. Overloads and namespaced twins get **distinct** FunctionKeys.

### AST `FinishDecl` stableKey (for contrast)

`asCSema::FinishDecl` (`as_sema.cpp` **13–78**), current format:

- Skip TU parent: translation units are module containers, not lexical namespaces.
- Optional `parentStableKey::` + name (destructor name forced to `~Name`).
- For function / method / constructor / destructor / mixin: append `(paramTypeStableKey,…)` from child `asAST_DECL_PARAM` types.
- Lambdas append `@<range.begin.offset>`.
- **No explicit kind token** in the string (kind is only implicit for `~` destructors). Return type and method `const` are still omitted.

Examples from Wave B dumps: `F(int)`, `F(float)`, `Game::F(int)`, `T::T()`, `T::T(int)`, `T::~T()`, `MixHelper(int)`, `<lambda>(int)@offset`.

The snapshot bind does **not** compare Runtime FunctionKey to this `stableKey`.

---

## 3. Concrete overload pair that mis-binds

### Script

```angelscript
int F(int a) { return 1; }
namespace N {
  int F(int a) { return 2; }
}
```

### Identity mismatch

| Runtime entity | FunctionKey facts (stable cache identity) | AST `stableKey` | Snapshot bind today |
| --- | --- | --- | --- |
| global `F` | namespace empty, declaration `int F(int)` | `F(int)` | name `F` + 1×`int` → **MatchCount = 2** → `CanonicalFunctionDeclValue = 0` |
| `N::F` | namespace `N`, declaration `int F(int)` | `N::F(int)` | same name+params → **MatchCount = 2** → `CanonicalFunctionDeclValue = 0` |

### Why this is still a wrong-body bind (not merely unbound)

1. Snapshot soft-skips DeclId (`0`) instead of failing generation.
2. TypedASTJIT eligibility still calls `FindFunctionDecl(SealedAST, DeclId{0}, nullptr)`.
3. Fallback returns the **first** function/method in the AST — global `F(int)` with body `return 1`.
4. Runtime `N::F` keeps **B’s FunctionKey / ABI** while analysis/emission can walk **A’s AST body**.

That is R03’s impact statement with the current code path.

### Same-module unique pair (now the live RED)

```angelscript
int F(float a) { return 0; }
int F(int a) { return a; }
```

Int binds (`F(int)`). Float stays DeclId 0 because Runtime `ttFloat64` is not in `PrimitiveAstTypeKey`. This is the exclusive UBT package `wave-b-jit-identity-float.md`. Do **not** treat green StaticJIT suites on uniquely typed overloads as proof that ambiguous same-name cases reject. Namespace twins are already GREEN via `stableKey` ns prefix.

### Existing coverage that does **not** close this

- `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` — dump/callee keys only (`CallSelectsExactIntOverloadNotFirstName`); no generation snapshot DeclId assert.
- `AngelscriptStaticJITGenerationEngineTests.cpp` — copies `SealedAST` / `CanonicalFunctionDeclValue` into compiled views; no ambiguous overload reject.
- TypedASTJIT CanonicalASTMigration adapter tests — inject a chosen DeclId; they never exercise snapshot matching.
- Many StaticJIT AOT fixtures use unique function names or still prefer VerifiedTypedHIR, so they can stay green with a wrong or zero AST DeclId.

---

## 4. TDD test to add (later session)

| Field | Proposal |
| --- | --- |
| New file | `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AngelscriptStaticJITCanonicalASTIdentityTests.cpp` |
| Prefix / class | `FAngelscriptStaticJITCanonicalASTIdentityTests` under `Angelscript.TestModule.StaticJIT.CanonicalASTIdentity` |
| Primary method | `AmbiguousSameNameOverloadsRejectAstBind_UniqueSignatureBinds` |

### Required assertions (do not weaken)

1. **Ambiguous reject** — script with global `F(int)` and `namespace N { F(int) }` (or two same name+param-count+type-key decls the matcher cannot uniquify):
   - For **each** Runtime FunctionKey, snapshot must **not** set `CanonicalFunctionDeclValue` to the first same-name decl.
   - Preferred contract for 13.3: generation / snapshot build **fails** (or TypedASTJIT eligibility hard-rejects) with an explicit ambiguous / signature-mismatch reason — not silent DeclId `0` plus first-function fallback.
   - Assert emission/eligibility does **not** observe global `F`’s body when resolving `N::F`’s FunctionKey.

2. **Unique bind** — script with `F(float)` and `F(int)` only:
   - Runtime `F(int)` binds the AST decl whose `stableKey` is `F(int)` (DeclId unique).
   - Runtime `F(float)` binds `F(float)`.
   - Match requires **name + param count + type key** (align with `FinishDecl` param type keys / complete signature), not name alone.

Do **not** accept “bind the first uniquely by bare name” as a passing oracle.

Suggested arrange: StaticJIT generation Engine, `asAST_RETAIN_SNAPSHOT`, compile the fixture module, `BuildAngelscriptStaticJITGenerationSnapshot`, then assert per-FunctionKey `CanonicalFunctionDeclValue` / reject status before any TypedASTJIT emit.

---

## 5. Files a later implementer may change

Production (plugin submodule):

- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/AngelscriptStaticJITGenerationSnapshot.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/Backends/AngelscriptStaticJITBackend.h` (compiled function view fields)
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCanonical.cpp` / `.h` — remove name-first / first-function `FindFunctionDecl` fallback; require exact DeclId
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/AngelscriptTypedASTJITEligibility.cpp` / `.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/TypedASTJIT/AngelscriptTypedASTJITBackend.cpp` (DeclId consumers)
- Optionally `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_sema.cpp` if bind must consume a stronger `stableKey` (kind / return / qualifiers) — coordinate with Wave B dump identity; do not invent a second key dialect
- Optionally `AngelscriptCacheStableSymbolIdentity.*` only if FunctionKey spelling must be compared to AST keys byte-for-byte

Tests:

- New `AngelscriptStaticJITCanonicalASTIdentityTests.cpp` (above)
- Possibly extend `TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp` once DeclId is mandatory
- Do not “fix” goldens by accepting first-name bind

OpenSpec (after green tests only): `tasks.md` notes for 13.3 / 7.2 / 7.4 — **do not check boxes from this attachment**.

---

## 6. What must stay `[ ]` until that test is green

| Task | Why blocked |
| --- | --- |
| **13.3** | R03 identity: complete stable signature + owner identity; Runtime FunctionKey↔AST mapping must **reject** ambiguous or signature-mismatched matches. Dump-side `F(int)`/`F(float)` progress is not generation reject. |
| **7.2** | TypedASTJIT Decl/Type/Stmt/Expr port still trusts snapshot DeclId / sealed AST; name-first or first-function fallback can attach the wrong body under B’s FunctionKey. |
| **7.4** | Call closure / provenance port cannot treat AST call nodes as authoritative while FunctionKey↔decl binding can point at the wrong (or first) decl. |

Hard no for the implementer: do **not** weaken “reject ambiguous” to “bind first uniquely by name”. Soft `CanonicalFunctionDeclValue = 0` plus `FindFunctionDecl` first-function fallback is **not** a pass.

---

## Quick return summary

| Field | Value |
| --- | --- |
| Bind function | `BuildAngelscriptStaticJITGenerationSnapshot` |
| Bind lines | **1139–1225** (FunctionKey **1117–1137**; function starts **967**) |
| Compared today | `Decl->stableKey.Equals(BuildRuntimeAstIdentityKey)`; unique float still `F()` vs AST `F(float)` because `ttFloat64` is unmapped |
| Proposed test | `FAngelscriptStaticJITCanonicalASTIdentityTests::AmbiguousSameNameOverloadsRejectAstBind_UniqueSignatureBinds` |
| Keep open | 13.3, 7.2, 7.4 |
