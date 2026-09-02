# Eighth-pass findings vs live `D:\as-cta` (2026-08-22, after B-56-body-owner)

Source: `reviews/implementation-rereview-2026-08-22-eighth-pass.md`.
Reviewer cutoff was **13:32** (ExprTerm WIP, SemaAuthority 206). Live intern is now Term identity GREEN, 5.4 dump, B-56 dump/oracles, Frontend Seal `decl-body` closed. **Request changes stands.** Do not archive. Do not check 13.2 / 5.4 / 5.6 / 9.5 / 4.2.

## Verdict after verification

The eighth-pass diagnosis is still accurate: Parser action peels are real, but incremental intern is still syntax-node replay + arena scan, not a Clang-shaped unique Sema action identity. F1 dump + `Make().Get()` execute-once landed. F2 InternParsedCall full-range reuse landed; `FindExistingExpr` is still kind+begin. F3 `QualTypeFromClassDecl` landed. F4 script intern + native `fileID==0` same-arity bind of `array<int>::insertLast` landed (SemaAuthority **227/227**, ProductionCodeGen **33/33**, CanonicalAST **276/276**). `RankArgument` still does not instantiate host template T. `EmitDeclRef` 1070 / OpaqueValue memo remain open.

Honest production cutover remains ~**30%**. Checklist `56/105` is 虚标. Reviewer 35–40% production readiness assumed the 13:32 snapshot; later intern peels closed F1 dump+eval-once, F2 CALL identity, F3 construct type, and F4 script intern + native array bind, but not RankArgument instantiate-T, F5 distinct-range identity, 1070, or F6–F10.

## Finding status (live file:line)

| Finding | Live? | Evidence now |
| --- | --- | --- |
| **F1** member call interned without receiver, then interned again; `Make().Get()` can eval receiver twice | **Dump + execute slice landed; 1070 / OpaqueValue memo still open** | Dump: `ParseFunctionCall(false)` for `.` postfix. SemaAuthority **214/214** `wave-b-f1-sema` / `wave-b-54-eval-once-sema`. Graph: one `callee=Make()`, one `callee=T::Get()` with `receiver=`. Execute: `CanonicalMemberPostfixCallEvaluatesReceiverOnce` Trace `"1,2"` result `1`. `EmitCall` reuses a child id already pushed in `argOffsets`; interned host `Trace` binds SYSTEM. Remaining 5.4: `EmitDeclRef` `:1070`, OpaqueValue passthrough, mutation traces. |
| **F2** Call reuse by ident offset; unresolved never reused; `FindExistingExpr` kind+begin only | **InternParsedCall slice landed; FindExistingExpr unchanged** | `FindExistingCallByFullRange` in `InternParsedCall` only (kind CALL + full begin/end). Unresolved and offset 0 reuse. SemaAuthority **219/219** `wave-b-f2-sema`. `FindExistingExpr` still kind+begin, skip 0. Not 13.2 / 13.3. |
| **F3** `T()` always `VALUE_OBJECT` | **Landed** | `QualTypeFromClassDecl`: script class → `REFERENCE_OBJECT` + handle quals; struct → `VALUE_OBJECT`. Dump `typeKind=`. SemaAuthority **222/222** `wave-b-eighth-f3-sema2`. CanonicalAST **271/271**. ABI matrix still open. |
| **F4** member fail → first same-arity method; unresolved DeclRef/Call → `int` | **Script intern + native instantiate landed** | Script same-arity walk deleted. Mixin fall-through with full args. Construction-API miss → ERROR `"<unresolved>"`. Parser-range DeclRef miss stays silent int. Native intern uses `DetermineTypeForTemplate` so `array<int>::insertLast(const T&in)` intern as `const int&in` and ranks over same-arity `bool`. fileID==0 same-arity remains defense. SemaAuthority **228/228** `wave-b-eighth-f4-rank-sema3`. CanonicalAST **277/277** `wave-b-eighth-f4-rank-canonical`. ProductionCodeGen **33/33** `wave-b-eighth-f4-prod4`. |
| **F5** Param/Enumerator bare-name reuse swallows true duplicates | **Landed** | Reuse is same owner + same source range. Distinct-range `Dup(int A, int A)` / `enum { Red, Red }` intern a second node + `duplicate-param:` / `duplicate-enumerator:`. Same-range replay has no diagnostic. SemaAuthority **236/236** `wave-b-eighth-f5-sema`. CanonicalAST **285/285**. Not 4.2 / 13.2. |
| **F6** type/layout/accessor/list/handle/value lifetime | **Yes** | CodeGen ABI remainder. Not this intern UBT. |
| **F7** `defaultArg` `"%d"` / `atoi` initializer channel | **Yes** | Not this intern UBT. |
| **F8** CodeGen not detached + atomic install | **Yes** | F6/9.1. Not now. |
| **F9** Verifier still publishes orphan CALL / missing callee | **Yes, with 2.8 constraint** | `asCASTVerify` still must succeed on **unsealed** construction graphs. Publication (`asCASTVerifyPublication`) is the unsealed gate. Do **not** make unsealed `asCASTVerify` require CALL `resolvedDecl`. Reviewer is right that publication of receiver-less CALL is a defect. |
| **F10** Cache DTO / snapshot ABI / CompileFunction / SourceManager | **Yes** | Wave E/F. Forbidden now. |

## What the 13:32 snapshot no longer describes

Do not treat the review's saved counts as current:

- Term identity GREEN SemaAuthority **208/208** `wave-b-term-sema2` (then **213/213** after 5.4/5.6 dump methods).
- 5.4 dump OpaqueValue / Sequence `literal=opaque` landed; Generate still fail-closes mutation; OpaqueValue emit still re-evals.
- B-56 `safepoint=` + skipped-nearer / default-order / fallthrough-target landed; **not** 5.6 close.
- Frontend Seal `decl-body` closed: BLOCK reuse only when `owner == fn`; ctor/dtor not collapsed by name. Frontend **85/85**, CanonicalAST **261/261**.
- Compiler prefix JSON can still have `succeededWithWarnings` (TypedSemanticIR SourceProvenance). Do not write pure `N/N PASS` if the report has a warning.

Reviewer ask to **re-audit checked 9.4 / 2.8 / 13.5**: 9.4 ordinary/member lowering is **not** complete (F1). 2.8 unsealed verify OK remains the construction contract; publication of CALL-without-callee is still a hole. 13.5 publication firewall is not 13.2 Sema authority.

## Suggested next exclusive UBT (after F5 identity GREEN)

**B-54 OpaqueValue memo / mutation** — after 1070 DeclRef bind. Map: `wave-b-54-generate-remaining.md`. 1070 class-member/for-init landed (`wave-b-54-1070-sema` **236/236**, no `line=1107`). Do not check 5.4.

F1 dump + eval-once, F2 intern, F3 construct type, F4 script intern + native instantiate, F5 Param/Enumerator range identity, 1070 DeclRef bind landed. Do not check 13.2 / 5.4 / 9.5 / 4.2.

Do **not**: Wave E–G; default CANONICAL; CANONICAL CompileFunction; require callee on unsealed `asCASTVerify`.

Rejected as *this* exclusive UBT: OpaqueValue memo; leftover `ActOnParsedExpr` default.
