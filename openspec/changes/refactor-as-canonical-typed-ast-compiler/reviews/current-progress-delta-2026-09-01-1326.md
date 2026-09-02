# Current progress delta — 2026-09-01 13:26 CST

This is the current auditable status of
`refactor-as-canonical-typed-ast-compiler` after CTA-S169. It supplements the
earlier 11:16 snapshot and keeps the review under this change's `reviews/`
directory.

## Headline

- Exact OpenSpec completion remains **107/136 = 78.7%**.
- Formal remaining rows remain **29**.
- Practical engineering completion is approximately **93% (±3%)**.
- The unchanged numerator is caused by broad umbrella rows, chiefly 5.3,
  5.4, 5.5–5.9, 7.2/7.4/7.5, 9.1/9.5–9.7, 10.x, and final verification.
- Product default remains **LEGACY**; Canonical default cutover is not yet
  authorized by the required matrix.

## Delta since the 11:16 snapshot

Eight additional gates moved the AST-first Sema boundary forward:

1. **CTA-S162:** leftover unary `!bool` is typed as `bool`.
2. **CTA-S163:** WorldContext hidden-call execution was characterized green;
   the Canonical publisher injects `__WorldContext()` exactly once.
3. **CTA-S164:** logical `Object && true` rewrites the object operand through
   `opImplConv` in Sema.
4. **CTA-S165:** Canonical staged factory, `CompileFunction`, and global-init
   paths no longer construct `asCCompiler` at the audited Builder sites.
5. **CTA-S166:** object functor calls such as `Object(41)` rewrite to
   `T::opCall(int)`; postfix `Make()(41)` is characterization-green through
   the same path.
6. **CTA-S167:** explicit `Cast<int>(Object)` rewrites through
   `T::opConv() const`.
7. **CTA-S168:** implicit `return Object` rewrites through
   `T::opImplConv() const`, excluding explicit `opConv`.
8. **CTA-S169:** local initialization `int Value = Object` now seals the same
   implicit conversion as a resolved Call before CodeGen.

These changes follow the LLVM/Clang separation being used by this OpenSpec:
Sema owns overload resolution, conversions, receiver/argument arrangement and
control/lifetime meaning; the sealed Canonical AST is immutable; Bytecode and
TypedASTJIT are lowering/code-generation consumers and may not rediscover
semantic intent.

## Fresh verification checkpoint

- CTA-S169 authentic RED: **0/1 FAIL** at
  `cta-sema-call-53-opimplconv-init-red/20260901_131237_872_d1e996b9`, for the
  expected missing sealed `opImplConv` Call.
- CTA-S169 focused Sema GREEN: **1/1 PASS** at
  `cta-sema-call-53-opimplconv-init-green/20260901_131349_241_cd61fc59`.
- CTA-S169 focused CodeGen GREEN: **1/1 PASS** at
  `cta-sema-call-53-opimplconv-init-codegen-green/20260901_131427_149_9e24b4d0`.
- SemaAuthority: **512/512 PASS**, zero failures/skips, at
  `cta-ast-first-sema/20260901_131504_061_96d355a1`.
- Frontend CanonicalAST: **189/189 PASS**, zero failures/skips, at
  `cta-ast-first-frontend/20260901_131648_284_c5dc602f`.
- ProductionCodeGen: **175/175 PASS**, zero failures/skips, at
  `cta-ast-first-prodcodegen/20260901_132413_481_dca91aa3`.
- Latest implementation build metadata at
  `Saved/Build/build/20260901_131334_743_b5834d62/RunMetadata.json` reports
  exit code 0.

These are focused/named-prefix checkpoints. They do not satisfy Task 12.2's
full prefix matrix or Task 12.4's configured All suite.

## Why 107/136 still has not moved

Task 5.3 is one checkbox covering the entire ordinary/member/mixin/import/
native call matrix, effective receivers, default/hidden/named arguments,
argument provenance/order, rewrites, route traits and stable dependencies.
CTA-S132–S169 close many concrete families, but the remaining inventory still
contains call-argument `opImplConv`, `opHndlAssign`, funcdef-variable calls,
remaining reverse operators, mixin/import execution leftovers, and converting-
constructor execution. Until that whole sentence is proven, 5.3 must remain
unchecked. The same pattern applies to 5.4–5.9 and the later backend/cutover
umbrellas.

Therefore **107/136 is a coarse checklist value, not a velocity measure**.
The meaningful recent movement is from SemaAuthority 504 cases / CodeGen 166
cases at CTA-S161 to 512 / 175 at CTA-S169, with all current named prefixes
green.

## Remaining critical path

1. Close the remaining 5.3 call/conversion families, then the 5.4 sequencing
   and 5.5–5.9 control/lifetime/language umbrellas.
2. Finish authenticated Canonical lifetime consumption in Bytecode and
   TypedASTJIT (7.2/7.4/7.5 and 9.1/9.5/9.6, plus 13.6).
3. Finish snapshot atomic publication/lease semantics (13.8).
4. Prove Canonical selection and remove the remaining semantic replay paths
   before default cutover (10.1–10.7/10.9 and 0.2/0.3).
5. Run the full focused matrix and All suite (12.2/12.4/13.12), then perform
   the requirement-by-requirement 136-row audit.

## Assessment

Use **78.7%** when reporting auditable OpenSpec checklist completion. Use
**about 93%** only as an engineering estimate: the implementation has advanced
substantially, but the riskiest remaining work is concentrated in semantic
completeness, backend proof, default cutover and final regression gates. There
is no external blocker; the constraint is closure breadth and proof density.
