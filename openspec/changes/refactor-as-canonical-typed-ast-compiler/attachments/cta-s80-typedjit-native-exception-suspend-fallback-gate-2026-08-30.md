# CTA-S80 TypedASTJIT native exception/suspend fallback gate — 2026-08-30

## Status

This non-Standalone slice closes one real TypedASTJIT direct-native safety gap
and one typed-fallback classification gap:

- a native descriptor carrying `MaySuspend` now selects the reviewed
  per-function `SuspendOrExceptionState` fallback before generic descriptor
  rejection can collapse it to `UnsupportedCall`;
- a descriptor that is otherwise direct-callable but may set a script
  exception now selects `ExceptionPayloadUnavailable` instead of being emitted
  as a bare direct symbol call without a proved exception payload route;
- the existing VM scalar bridge remains eligible for
  `MaySetScriptException`, because it already executes through a nested AS
  context and adopts the first failure into the caller.

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2, 7.4 and 7.5
are umbrella tasks and still have other open families. The architecture-weighted
non-Standalone estimate is now approximately **89%**. Safe product-default
readiness is approximately **71%**; the product default remains LEGACY.

## Problem and route audit

The native-call descriptor retains both
`EAngelscriptStaticJITNativeCallRouteFlags::MaySuspend` and
`EAngelscriptStaticJITNativeCallExceptionPolicy` through registry capture,
generation snapshots and `FAngelscriptStaticJITNativeCallTarget`. The data was
not lost before TypedASTJIT. The defect was how closure planning interpreted it.

The Runtime descriptor validator intentionally has different contracts for
the three supported route families:

| Route | `MaySuspend` | `MaySetScriptException` | Existing exception mechanism |
| --- | --- | --- | --- |
| Direct symbol/inline/thunk | rejected by current scalar route validation | accepted | bare native call; no proved `FScriptExecution` payload/adoption route |
| VM scalar bridge | rejected | accepted | nested VM context plus first-failure adoption |
| Current native binding | rejected in the reviewed route contract | rejected | bound-native execution-state route, currently restricted to `DoesNotSetScriptException` |

Before CTA-S80, every descriptor validation failure was converted to the
generic TypedASTJIT reason `UnsupportedCall`. Therefore `MaySuspend` failed
closed safely, but its reviewed semantic category was lost. More importantly,
direct + `MaySetScriptException` passed descriptor validation, selected a
direct disposition and reached emission.

Direct native emission writes a bare symbol invocation. It does not pass a
`FScriptExecution`, does not poll `bExceptionThrown` after the call and has no
defined failure-record adoption protocol. The outer provider wrapper owning an
execution object does not repair that missing direct-call ABI relation.

The bridge route is materially different. `InvokeBoundViaVM()` executes a
nested AngelScript context under nested exception adoption and calls the
existing context-exception adoption path. Existing tests already prove the
message/origin/first-failure behavior. Rejecting every
`MaySetScriptException` descriptor would therefore have disabled a safe and
useful route.

## AST-first/closure-first RED

Two production-boundary mutation tests were added to
`AngelscriptStaticJITGenerationEngineTests.cpp`:

1. `MaySuspendNativeCallUsesTypedSuspendFallback`
   - captures an ordinary reviewed native target;
   - adds `MaySuspend` to its immutable test copy;
   - requires the selected function to be ineligible with
     `SuspendOrExceptionState` and stable detail `NativeCallMaySuspend`.
2. `DirectNativeExceptionPolicyRequiresTypedPayloadRoute`
   - captures a direct header-inline target;
   - changes its exception policy to `MaySetScriptException`;
   - requires `ExceptionPayloadUnavailable` and stable detail
     `DirectNativeExceptionPayloadUnavailable`.

The correct RED class run was **32/34 PASS, 2 expected failures**. Both new
tests failed for the intended production behavior. An earlier invocation used
an incomplete CQTest path, matched zero tests and is explicitly not evidence:

- non-evidence zero-match run:
  `Saved/Tests/cta-s80-native-exception-suspend-red/20260830_075850_302_4c56962e`;
- valid RED run:
  `Saved/Tests/cta-s80-native-exception-suspend-red2/20260830_075938_509_78f28d6d`.

This runner correction is also an execution-process reminder: test discovery
or zero-match output is never counted as a RED/GREEN result. The final CQTest
path includes the generated C++ test-class segment.

## Resolution

`AngelscriptTypedASTJITCallClosure.cpp::PlanNativeCall()` now owns two explicit
semantic gates before an emission disposition can be selected:

1. after copying a non-absent descriptor, any `MaySuspend` flag records
   `SuspendOrExceptionState` with the exact call source span and stops closure
   planning before the Runtime validator's generic rejection path;
2. after successful descriptor validation, a target that is both
   `bDirectCallable` and `MaySetScriptException` records
   `ExceptionPayloadUnavailable` with the exact call span and stops before
   direct disposition selection.

The second gate intentionally checks the validated direct capability. It does
not reject the VM scalar bridge, and CurrentNative continues to use its
stricter existing descriptor contract. No provider ABI, entry ABI or native
call descriptor layout was changed.

This is a fail-closed capability gate, not an implementation of direct native
exception payload support. Supporting that route later would require an
explicit direct ABI for current execution state, complete failure-record
ownership, post-call propagation, cleanup ordering and provider compatibility.

## Verification evidence

| Gate | Result |
| --- | --- |
| RED build | PASS — `Saved/Build/cta-s80-native-exception-suspend-red-build/20260830_075826_704_85f3bc29` |
| Correct RED class run | **32/34 PASS, 2 expected failures** — `Saved/Tests/cta-s80-native-exception-suspend-red2/20260830_075938_509_78f28d6d` |
| GREEN build | PASS — `Saved/Build/cta-s80-native-exception-suspend-green-build/20260830_080257_966_d9b53904` |
| Focused GREEN | **2/2 PASS** — `Saved/Tests/cta-s80-native-exception-suspend-green-focused/20260830_080314_928_6633555b` |
| Full ProjectGeneration Engine class | **34/34 PASS** — `Saved/Tests/cta-s80-native-exception-suspend-green-class/20260830_080357_575_f27f1b3f` |
| Compiler CanonicalAST + TypedASTJIT | **693/693 PASS** (**639+54**) — `Saved/Tests/cta-s80-compiler-typedjit-full-green/20260830_080730_741_cf39cea5` |

All recorded GREEN runs have zero failures and zero skips. The full class run
includes `ProviderPrivateGenericVMBridgeIsFrozenAndEmittedByTypedAST`, proving
that the precise direct gate did not disable the existing bridge emission
route. The combined 693-test gate preserves the current Canonical compiler and
TypedASTJIT baseline.

An independent read-only subagent audited the descriptor, generation snapshot,
closure, emission and nested-bridge paths. It made no edits and ran no build.
Its conclusion matched the main-thread implementation boundary: direct +
`MaySetScriptException` was the real safety gap, `MaySuspend` was a typed reason
gap, and bridge + `MaySetScriptException` must remain eligible because adoption
already exists.

## Remaining exception/suspend diagnostics and non-claims

CTA-S80 closes unsafe eligibility/emission and precise fallback selection for
these native descriptor facts. It does not close all exception/suspend work:

- `FAngelscriptTypedASTJITCanonicalLifetimeFacts::bHasSuspendState == false`
  is the truthful current Canonical language fact. Current `asBC_SUSPEND` is a
  poll/safe-point mechanism rather than a cooperative resumable frame. Native
  descriptor `MaySuspend` is a call-edge/environment capability and must not
  manufacture a language-lifetime producer. A future resumable language
  construct would be the correct producer for `true`.
- CTA-S81 subsequently closed the provider aggregate diagnostic defect. Every
  production Provider root owns the direct execution frame/failure record, and
  any closure that emits a VM bridge is now reported as
  `DirectFailureRecordAndNestedBridgeAdoption`. Bound-call infrastructure
  failures also retain a structured first-failure payload. Evidence:
  `attachments/cta-s81-typedjit-exception-payload-aggregate-gate-2026-08-30.md`.
- language/compiler exception-region facts, future suspend-capable language
  constructs, and a complete diagnostic source of truth still need explicit
  Canonical facts and tests.
- immutable native-target binding, import/mixin/property/cross-TU call
  families, mutable global/import lifecycle routes and remaining provider
  dependency closure keep 7.2/7.4/7.5 open.

No Standalone source or test was touched. No AST dump, HIR adapter or bytecode
body analysis was introduced. This slice does not switch the default to
CANONICAL, run the final All suite, close the cutover matrix or authorize
removal of the original native AngelScript parser AST.
