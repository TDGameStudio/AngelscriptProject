# Gate card: S8 declaration Sema ownership（2026-08-26）

- **OpenSpec task(s):** `4.2`, `4.3`, `4.4`, `4.5`, `4.6`
- **Source fixture:** compile-seal `Entry` owns mixin `MixHelper(T self, int a = 40 + 1)`, overload `F(int)`/`F(float)`, and two IIFE lambdas. A sibling Parser→Seal unit owns `interface IProbe` and `class T : IProbe` (Canonical CodeGen still fail-closes Interface).
- **Canonical fact:** declaration Sema owns the graph. Mixin is `MixHelper(T,int)` with `origin=T`, `deps=T`, and param `a` owning Binary `40+1` (filled at the omitted-arg call). `F(1)` binds `F(int)` not `F(float)`. Two `<lambda>(int)@offset` keys stay distinct on Build(). `T.bases` records `IProbe` on the sealed inheritance unit. Parser `asCScriptNode` is recovery only for these facts.
- **AST test:** `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` / `DeclarationSemaOwnsSignaturesMixinLambdaAndBasesOnCompileSealPath`
- **AST-red:** `Saved/Tests/cta-s8-sema-decl-red/20260826_234841_199_caee6e31` — 0/1. Combined Build fixture seals mixin `MixHelper(T,int)` `deps=T`, Binary `40+1` param init, `F(int)`, and distinct lambda keys. `T : IProbe` seals `bases`. Mixin `origin` is empty. First Interface Build attempt failed CodeGen (`unsupported declaration kind Interface`) and is not the AST-red.
- **AST-green:** `Saved/Tests/cta-s8-sema-decl-green/20260826_234950_571_b51db429` — 1/1. Mixin `origin=T`. Compile-seal also keeps `MixHelper(T,int)` `deps=T`, Binary `40+1`, `F(int)`, distinct lambda keys. Parser→Seal `T : IProbe` records `bases`.
- **CodeGen/provenance:** Sema/dump only this slice. Do not check `4.2`–`4.6` (Builder remains production registration; Canonical CodeGen still fail-closes Interface; no complete shadow-mismatch oracle against `asCBuilder`; no HIR cutover).
- **Lifecycle:** none.
- **Remaining boundary:** namespace `Game::F` still parse-seal only (Canonical CodeGen does not publish namespaces). Script `funcdef` stays rejected. Full builder-vs-Sema mismatch oracle is not this slice. S9 is next.
