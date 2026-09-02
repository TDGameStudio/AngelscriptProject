# CTA-S81 TypedASTJIT exception payload and aggregate diagnostic gate — 2026-08-30

## Status

This non-Standalone slice closes the structured first-failure and aggregate
diagnostic defects left explicit by CTA-S80:

- bound-call infrastructure failures now publish a structured
  `asSJITFailureRecord` rather than only setting
  `FScriptExecution::bExceptionThrown`;
- a successful direct-only or CurrentNative Provider closure reports
  `DirectExecutionState` + `DirectFailureRecord`;
- a successful closure that actually emits a VM bridge reports
  `DirectExecutionState` +
  `DirectFailureRecordAndNestedBridgeAdoption`, preserving both mechanisms;
- an already-adopted nested VM failure remains the first failure when the
  outer bridge returns `ExecutionFailed`.

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2, 7.4 and 7.5
are umbrella tasks with other call/dependency/lifetime families still open.
The product default remains LEGACY. Standalone was neither changed nor run.

## Problem

Every successfully emitted TypedASTJIT Provider root already executes under
the shared `FScopeTypedASTJITExecutionFrame`. That frame owns the direct
first-failure record used by generated guards and CurrentNative resolution.
However, the bound-call bridge helper's early `Fail()` path only performed:

```text
Execution.bExceptionThrown = true
```

Missing Engine state, missing or wrong reference slots, wrong-Engine bindings
and unsupported installed calling forms therefore had control-state evidence
but no message, route origin or adopted/direct ownership in the public failure
payload.

The generation diagnostic had the complementary truth defect. Every successful
Provider closure was unconditionally stamped as:

```text
DirectExecutionState + DirectFailureRecord
```

That is complete for a direct-only or CurrentNative closure, but incomplete
for a closure containing a VM bridge. `InvokeBoundViaVM()` executes a nested AS
context and adopts its first script failure into the outer record. A mixed
closure consequently owns both a direct record and a nested adoption route.
Selecting either one as the aggregate would erase a real mechanism.

## Frozen contract

The production contract after CTA-S81 is:

| Emitted Provider closure | Control state | Payload state |
| --- | --- | --- |
| Direct-only | `DirectExecutionState` | `DirectFailureRecord` |
| CurrentNative-only | `DirectExecutionState` | `DirectFailureRecord` |
| Any closure containing an emitted VM bridge | `DirectExecutionState` | `DirectFailureRecordAndNestedBridgeAdoption` |

`NestedBridgeAdoption` remains a representable diagnostic value for future
unwrapped or synthetic execution contexts, but a current production Provider
root always owns the mandatory direct frame. The aggregate describes the set
of exception mechanisms available in the emitted closure; structured call-site
diagnostics continue to describe the route of each individual call.

This does not change Provider entry ABI or the native-call descriptor layout.
The new value is pointer-free diagnostic output.

## RED evidence

Two independent assertions were introduced before the implementation:

1. `BoundCallInfrastructureFailuresOwnStructuredFirstFailurePayload`
   requires VM-bridge and CurrentNative missing-Engine failures to retain a
   non-adopted first-failure record, route origin `generated-native-call`, and
   a message naming the exact `EAngelscriptTypedASTJITBridgeResult`.
2. `ProviderPrivateGenericVMBridgeIsFrozenAndEmittedByTypedAST` requires a
   production mixed closure not to collapse to either the direct-only or the
   nested-only aggregate.

The RED build passed and the exact test pair was **0/2** for the intended
reasons:

- build:
  `Saved/Build/cta-s81-exception-payload-diagnostic-red-build/20260830_081858_911_2a7bf063`;
- RED pair:
  `Saved/Tests/cta-s81-exception-payload-diagnostic-red/20260830_081924_731_367b6584`.

The payload assertion found no `FailureRecord`; the production diagnostic
assertion found the old direct-only state.

## Resolution

### Structured bound-call failure ownership

`AngelscriptTypedASTJITCallBridge.cpp::Fail()` now formats the exact bridge
result and routes it through `FStaticJITFunction::SetExternalException()`.
That helper sets the execution control bit and tries to record the direct
failure with the existing first-failure protocol. If a nested VM exception was
already adopted, its message/origin remains authoritative and the outer
`ExecutionFailed` result cannot overwrite it.

Expected negative-path tests now use the existing scoped expected-exception
log suppression. This is a test-fixture correction: the new production payload
made an intentionally rejected call visible as an Error log, while the test had
previously relied on the incomplete bool-only failure.

### Aggregate reducer

`AngelscriptTypedASTJITBackend.cpp` no longer stamps a constant payload state.
After emitted call diagnostics are recorded, the reducer scans the structured
`NativeCallSites` of the actual emitted root/closure members:

```text
no Bridge route -> DirectFailureRecord
one or more Bridge routes -> DirectFailureRecordAndNestedBridgeAdoption
```

It does not inspect generated C++ text, parse AST dumps or reconstruct retired
HIR records. The exact combined enum spelling is serialized by
`StaticJITDiagnostics.cpp`, and the AOT diagnostic test proves the JSON value.

## Suspend-state correction

CTA-S81 also corrects a stale interpretation recorded after CTA-S80.
`FAngelscriptTypedASTJITCanonicalLifetimeFacts::bHasSuspendState == false` is
truthful for the current Canonical language model. Current `asBC_SUSPEND`
behavior is a poll/safe-point mechanism, not a cooperative resumable frame with
a Canonical lifetime continuation state.

The native descriptor flag `MaySuspend` is a call-edge/environment capability
and already selects the typed `SuspendOrExceptionState` fallback. It must not
set a language-lifetime field merely to create a producer. A future language
construct with an actual resumable frame would be the correct producer for
`bHasSuspendState=true`.

## Verification evidence

| Gate | Result |
| --- | --- |
| RED build | PASS — `Saved/Build/cta-s81-exception-payload-diagnostic-red-build/20260830_081858_911_2a7bf063` |
| Exact RED pair | **0/2 expected failures** — `Saved/Tests/cta-s81-exception-payload-diagnostic-red/20260830_081924_731_367b6584` |
| GREEN build | PASS — `Saved/Build/cta-s81-exception-payload-diagnostic-green-build/20260830_082411_778_f2a3a1a7` |
| Fixture-correction incremental build | PASS — `Saved/Build/cta-s81-exception-payload-diagnostic-green-test-fixture-build/20260830_082634_341_3d320293` |
| Exact payload/aggregate/JSON GREEN | **3/3 PASS** — `Saved/Tests/cta-s81-exception-payload-diagnostic-green-focused/20260830_082445_569_d6228dfe` |
| Complete NativeBridge class | **10/10 PASS** — `Saved/Tests/cta-s81-exception-payload-diagnostic-green-nativebridge-class/20260830_082658_287_53a15c7e` |
| ProjectGeneration Engine + AOT Diagnostics Generation | **38/38 PASS** — `Saved/Tests/cta-s81-exception-payload-diagnostic-green-generation-classes/20260830_083017_642_1bd6765c` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **703/703 PASS**, zero failures/skips — `Saved/Tests/cta-s81-compiler-typedjit-nativebridge-full-green/20260830_083338_245_2adaa5ea` |

An earlier combined class run was manually stopped after the expected negative
call produced an unsuppressed Error log:
`Saved/Tests/cta-s81-exception-payload-diagnostic-green-classes/20260830_082523_415_9d7230b3`.
It is explicitly not verification evidence. The scoped fixture correction and
complete **10/10** NativeBridge rerun replace it.

The broad **703/703** rerun is the latest aggregate regression evidence for
this slice. It combines the complete Compiler CanonicalAST, TypedASTJIT and
NativeBridge prefixes and reports zero failures and zero skips.

An independent read-only subagent audited the execution frame, direct failure,
nested adoption and unconditional diagnostic-stamping paths. It made no edits
and ran no tests. Its finding matched the main-thread contract: current
production Provider roots require a combined value whenever a VM bridge is
emitted, while `bHasSuspendState` remains a Canonical language fact rather than
a native descriptor projection.

## Remaining work and non-claims

CTA-S81 closes the reviewed payload and aggregate diagnostic defect. It does
not close 7.2, 7.4 or 7.5:

- native targets still need a verifier-authenticated immutable relation instead
  of declaration-string reconciliation in generation capture/closure planning;
- receiver lowering, import/mixin/property/constructor/delegate/lambda,
  mutable-global and cross-TU call families remain incomplete or explicit
  fallback;
- native object-frame cleanup and remaining provider dependency families are
  not claimed;
- complete language-level exception/suspend constructs would need their own
  Canonical facts if introduced later.

No dump, HIR adapter, bytecode body analysis or Standalone branch was added.
This slice does not switch the default to CANONICAL, run the final All suite,
archive the change or authorize removal of the original native AngelScript
parser AST.
