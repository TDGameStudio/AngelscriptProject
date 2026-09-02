# CTA-S174 compile-out call rewrite review — 2026-09-01

## Review result

No blocking correctness finding remains in the CTA-S174 implementation after
the V12 wrapper correction. The implementation follows the approved
LLVM/Clang-shaped boundary: Runtime registration is an input to Sema; Sema
publishes immutable semantic facts; verifier, Sidecar and CodeGen consume those
facts without re-running overload or compile-out policy.

Formal OpenSpec completion remains **107/136 = 78.7%**, with **29** rows open.
CTA-S174 is an internal milestone inside open Task 5.3, so it cannot change the
formal numerator. Evidence-weighted overall maturity is now approximately
**81%**. Task 5.3 itself is approximately **97%** complete and has one explicit
acceptance item left: import bind/rebind/unbind snapshot immutability.

## Findings

### Closed during review: Cache wrapper schema skew

The maintained fork advanced to Sidecar V12, but
`FAngelscriptCacheASTBodySidecar::SchemaVersion` remained V11. The first full
Cache run therefore failed in production capture with error `2`
(`asAST_SIDECAR_UNKNOWN_KIND`) before an existing ExactWarm negative fixture
could perform its intended mutation. Synchronizing the wrapper to V12 restored
the fixture; the exact regression is **1/1 PASS**.

### No remaining blocking finding: semantic authority

- The three dispositions are declaration traits, not backend queries.
- Every `CallRewrite` has a verifier-authenticated final-value shape.
- Discarded unresolved operands produce neither diagnostics nor dangling nodes.
- CodeGen has no `compileOutType` branch and executes only retained children.
- V12 preserves the full rewrite relation byte-exactly.

### Residual scope, not a CTA-S174 defect

The generic call oracle does not prove copy-constructor, destructor, or
specialized operator/lifecycle `compileOutType` sites. Those remain mapped to
their owning expression/lifetime umbrellas. Task 5.3 also remains open for the
historical import bind/rebind/unbind characterization. Native ABI/bridge state
belongs to Task 7.4's immutable binding snapshot, not `CallExpr`.

## Current percentage model

| Scope | Auditable state | Current assessment |
|---|---:|---:|
| OpenSpec checkboxes | 107/136 | **78.7%** |
| Canonical AST foundation, declarations, types, public ownership | sections 1–4, 11, 14, 15 complete | **>95%** |
| Task 5.3 call-family closure | compile-out closed; import immutability remains | **~97%** |
| Expression/control/sequencing umbrella (section 5 overall) | 3/10 formal rows complete | **~70%** engineering maturity |
| TypedASTJIT and Bytecode consumer closure (sections 7 and 9) | 10/17 formal rows complete | **~60–70%** |
| Default cutover/LEGACY isolation (section 10) | 2/9 formal rows complete | **~40–50%** |
| Final matrix/archive readiness | section 12 is 4/6; final all-suite work remains | **~65%** |
| Evidence-weighted whole change | risk-weighted, not a task count | **~81%** |

The older engineering estimate of about 93% was too optimistic because it
weighted landed semantic families heavily while underweighting default
cutover, backend independence, deletion gates, and final regression cost. The
81% estimate is intentionally more conservative and tracks remaining risk as
well as code volume.

## Why the formal value has plateaued

Task 5.3 is one checkbox but contains ordinary/member/mixin/import/native calls,
receivers, named/default/hidden arguments, provenance/order, rewrites, route
traits, stable dependencies, and every historical `TypedSemanticIR/Call*`
oracle. CTA-S132 through CTA-S174 can close many independently tested families
without incrementing the checkbox numerator. The same bundling exists in 5.4–
5.9, 7.2/7.4/7.5, 9.1/9.5–9.7 and 10.x. The plateau is therefore granularity,
not inactivity.

## Verification reviewed

- implementation build after V12 synchronization: PASS;
- focused former Cache failure: **1/1 PASS**;
- exact Sema/CodeGen/Sidecar: **3/3 PASS**;
- complete SemaAuthority + ProductionCodeGen: **760/760 PASS**;
- complete Cache V12: **586/586 PASS**, zero failures/skips, at
  `Saved/Tests/cta-sema-call-53-compile-out-cache-full-v12-sync-20m/`
  `20260901_161845_558_ff4efab4`;
- complete Frontend CanonicalAST: **189/189 PASS**, zero failures/skips, at
  `Saved/Tests/cta-sema-call-53-compile-out-frontend-full/`
  `20260901_163611_064_86070975`;
- post-schema-guard build: PASS at
  `Saved/Build/cta-sema-call-53-compile-out-schema-guard/`
  `20260901_161823_410_fcf87787`.

The first complete-Cache attempt used a 10-minute budget and was terminated
after 347 successful tests with no failures. It is not counted as a green gate;
the independently restarted 20-minute run above is the authoritative complete
result.

Detailed architecture and test paths:
`attachments/canonical-compile-out-call-rewrite-gate-2026-09-01.md`.

## Next closure point

CTA-S175 should bind the same imported slot to provider A, rebind it to provider
B, unbind it, and prove after every mutation that the retained Canonical
snapshot is byte/dump-identical and still names the same `ImportDecl`, stable
signature, source module, result type, call arguments and `resolvedDecl`.
Execution must change `11 -> 29 -> exception` solely through Runtime binding
state. If that characterization and the final source/history audit pass, Task
5.3 can be checked and formal progress becomes **108/136 = 79.4%**.
