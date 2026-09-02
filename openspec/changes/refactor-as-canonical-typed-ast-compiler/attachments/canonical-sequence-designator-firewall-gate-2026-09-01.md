# Canonical Sequence designator firewall gate (CTA-S176)

## Decision under test

Task 5.4 requires Sema to publish the exact executable sequencing graph. A
Frozen/Publishable `Sequence` may contain value-producing or side-effecting
semantic expressions, but it must not carry a parser/compiler designator that
only names a function-like declaration or class. Those designators belong to
the resolved `Call` / `Construct` semantic form, not to CodeGen's execution
list.

This follows the approved Clang-shaped boundary: Sema may use explicit
`OpaqueValueExpr`-style nodes when one source must be evaluated once and reused;
the backend must not infer a `PseudoObjectExpr`-style semantic form by skipping
apparently non-executable children.

## Focused AST-first evidence

- Test source:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- Real source method:
  `CompileSealCallAndConstructDesignatorsNeverBecomeSequenceSteps`
- Forged-graph firewall methods:
  `VerifierRejectsNonExecutableFunctionDeclRefInSequence` and
  `VerifierRejectsNonExecutableClassDeclRefInSequence`
- Source fixture: CANONICAL-retained `C Make()` plus
  `return Make().Get() + 1`, exercising class construction, a global call and a
  member call on a compiler-generated receiver.
- Required sealed/public facts:
  every `Call` has a resolved declaration and dispatch; no direct `Sequence`
  child is an unresolved `Call` or a `DeclRef` naming Function, Method,
  Constructor, Destructor, Mixin or Class; publication verification succeeds.
- Required negative fact: a hand-authored executable `Sequence` containing a
  function/class designator is rejected with stable detail
  `sequence-non-executable-designator` before CodeGen.

## TDD state

- RED: **2/2 expected failures** at
  `Saved/Tests/cta-sema-sequence-54-designator-red-v2/20260901_172221_619_6412d0b6`.
  Both forged function/class designators were accepted before the production
  change, proving that the new tests exercised the missing firewall.
- Focused GREEN: forged negatives **2/2 PASS** at
  `Saved/Tests/cta-sema-sequence-54-designator-green/20260901_172423_686_1e26bc5f`;
  real-source publication **1/1 PASS** at
  `Saved/Tests/cta-sema-sequence-54-designator-source-green/20260901_172459_514_98220398`.
- Complete SemaAuthority: **536/536 PASS**, zero failures/skips, at
  `Saved/Tests/cta-sema-sequence-54-designator-sema-full/20260901_172620_289_e0119010`.
- Complete ProductionCodeGen: **229/229 PASS**, zero failures/skips, at
  `Saved/Tests/cta-sema-sequence-54-designator-prodcodegen-full/20260901_172802_571_5da83ebb`.
- Complete Frontend CanonicalAST: **189/189 PASS**, zero failures/skips, at
  `Saved/Tests/cta-sema-sequence-54-designator-frontend-full/20260901_173432_099_528daca5`.
- Build: **PASS** at
  `Saved/Build/cta-sema-sequence-54-designator-green/20260901_172404_949_a20199e1`.
- Static record gates: parent/plugin `git diff --check` exit 0 (plugin reports
  informational future LF-to-CRLF normalization warnings only), and
  `openspec validate refactor-as-canonical-typed-ast-compiler --strict`
  reports the change valid.
- CodeGen/publisher result: ordinary Sequence emission no longer skips an
  unresolved receiver-less Call or a function/class DeclRef. Publication owns
  resolved Call targets/dispatch; the generic verifier now rejects direct
  non-executable function/class designators with stable detail
  `sequence-non-executable-designator`.
- Cache V2/V12: **deferred by scope**, not a CTA-S176 acceptance gate. This
  slice changes neither cache bytes nor the serialization protocol. The
  complete Cache run started under label
  `cta-sema-sequence-54-designator-cache-full-v12` was intentionally stopped
  after the user reconfirmed that Cache V2/V12 remains a later standalone
  refactor; the interrupted run is not reported as pass or failure. The prior
  committed V12 baseline remains 586/586 PASS.
- Lifecycle result: no new lifetime action is introduced. Existing
  `OpaqueValue`, `MaterializeTemporary`, and authenticated lifetime protocol
  semantics remain unchanged and must stay green.

## Non-claims

CTA-S176 is one Task 5.4 slice. It does not by itself close the complete
property/index/mutation, control-flow, temporary, compiler-generated-value, or
legacy/canonical side-effect-trace matrix, and it does not accept Task 13.2 or
the production cutover.
