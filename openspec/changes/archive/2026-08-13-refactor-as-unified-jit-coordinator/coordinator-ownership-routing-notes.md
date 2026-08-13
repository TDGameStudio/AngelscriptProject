# Coordinator Ownership And Routing Notes

## Scope

This attachment records implementation evidence and problems discovered while
working through tasks 6.1-6.5. The checklist remains the concise source of task
status; this file preserves the reasoning and reproducible validation details.

## Implemented Ownership Boundary

- `FAngelscriptEngine` now creates exactly one
  `FAngelscriptJITCoordinator` and installs it as the Engine's only
  `asIJITCompiler`.
- The coordinator owns maintained-fork function-ready, JIT-entry, and Binding
  release callbacks. Runtime factories and sessions never call
  `SetJITCompiler()`.
- The temporary `FAngelscriptStaticJIT` lifecycle facade was removed after the
  coordinator lifecycle tests were green. Static generation remains in
  `FAngelscriptStaticJITGenerator`, `FAngelscriptJITGeneration`, and
  `FAngelscriptBytecodeJIT`; the compatibility generation entry points remain.
- Each coordinator allocates a distinct Engine namespace and creates at most
  one selected Runtime request state machine/session for that Engine.
- Runtime Binding userdata is recognized through the coordinator-owned
  `FAngelscriptRuntimeJITBindingContext` registry. Published Runtime Bindings
  contain VMEntry only and retain both the immutable result and its code lease.

## Tier And Safe-Point Ordering

The Engine processes tiers in the following order:

1. Authoritative compilation publishes a verified immutable function-route
   snapshot.
2. `FAngelscriptJITProviderRouter` selects or clears exact Static AOT Bindings.
3. The coordinator consumes the resulting current routes at the same Engine
   safe point.
4. In `Auto`, an exact AOT Binding suppresses/retire-drops Runtime work for that
   function. If AOT is absent, the selected Runtime backend may publish a
   VMEntry-only Binding. Otherwise the function remains VM.

`VMOnly` clears/bypasses both native tiers, `StaticAOTOnly` never creates
Runtime work, and `RuntimeOnly` clears/bypasses AOT before observing Runtime
snapshots. Tick and module-discard boundaries also process pending Runtime
results. The maintained fork's `asBC_JitEntry` invokes the coordinator lazy
claim hook, but the claiming invocation deliberately continues with its
already-retained VM path; only later invocations may observe the published
Runtime Binding.

Runtime capture still requires `bHasVerifiedArtifactIdentity`. A test helper
that directly called `BuildModule` initially produced unverified routes and the
coordinator correctly refused capture. The routing fixture was changed to use
the production `InitialCompile`/Cache V2 capture path instead of weakening this
safety check.

## TDD And Validation Evidence

### RED evidence

- Runtime routing test initially expected two Engine-local sessions but
  observed zero because the coordinator did not yet consume Runtime snapshots:
  `Saved/Tests/jit-coordinator-runtime-routing-red/20260814_031629_089_0b8889e2`.
- Configuration/lifecycle tests first failed before the explicit coordinator
  mode parser and Engine ownership were implemented:
  `Saved/Build/jit-coordinator-config-red/20260814_030730_402_5b875668`.
- Review added a real routing case for invalid Runtime configuration isolation.
  It failed because the shared validity bit also disabled exact Static AOT:
  `Saved/Tests/jit-coordinator-config-isolation-red/20260814_040511_000_4941b6a3`.

### GREEN evidence

- Coordinator configuration/lifecycle tests: `3/3 PASS`:
  `Saved/Tests/jit-coordinator-config-green/20260814_031424_734_030b4bd6`.
- Initial Runtime routing tests: `3/3 PASS`:
  `Saved/Tests/jit-coordinator-modes-green/20260814_033803_653_210f6e4b`.
- Exact AOT precedence and retirement fallback extended the routing group to
  `4/4 PASS`:
  `Saved/Tests/jit-coordinator-aot-precedence-green/20260814_034240_683_017700b2`.
- The matching fresh Editor build passed:
  `Saved/Build/jit-coordinator-aot-precedence-green/20260814_034223_426_2b8452ff`.
- After review fixes, the final 136-action Editor build passed:
  `Saved/Build/jit-coordinator-review-fixes-green-final/20260814_041544_410_70154dea`.
- The complete Coordinator lifecycle/routing prefix passed `38/38`:
  `Saved/Tests/jit-coordinator-group6-final-green/20260814_042114_253_31270bb6`.
- Focused Static JIT compatibility passed: Editor routing `8/8` at
  `Saved/Tests/jit-coordinator-review-static-routing/20260814_042303_991_58e5b1fe`,
  Binding publication/lifetime `5/5` at
  `Saved/Tests/jit-coordinator-review-static-binding/20260814_042435_074_a0df794b`,
  and generated output `6/6` at
  `Saved/Tests/jit-coordinator-review-generated-output/20260814_042548_406_f1ebe318`.

The routing coverage proves:

- two Engines selecting the same fake backend get different namespaces,
  separate sessions, separate Bindings, and independent teardown;
- LazyFirstCall leaves the claiming invocation on VM and publishes only for a
  later call;
- `Auto` falls back to Runtime on an AOT miss while `VMOnly` remains VM;
- an exact AOT provider wins before Runtime in `Auto` (`CompileCount == 0`),
  and provider retirement causes the current function to fall back to Runtime;
- Runtime session and executable-code lease ownership release exactly once.

## Problems And Resolutions

- A normal three-minute build timeout expired around action 116/136. The same
  build was rerun through `Tools/RunBuild.ps1` with its timeout raised to 30
  minutes and passed. This was build duration, not a compiler failure.
- Terminating the outer build runner did not immediately terminate an already
  launched XGE child, briefly producing a maximum-concurrent-build conflict.
  No destructive cleanup was used; the existing child was allowed to finish
  before retrying.
- A forward declaration used `class` for a project type declared as `struct`,
  producing C4099. The declaration was made consistent with the owning type.
- The exact-AOT test registers a process-global provider. It now installs a
  scope-exit cleanup immediately after successful registration so an assertion
  failure cannot leave a dangling provider owner that contaminates later
  automation tests.
- Review found that the temporary facade's inert per-Engine BytecodeJIT member
  had been moved into the coordinator. It was removed: Static generation stays
  task-local, and the POD type classifier is invoked explicitly from the
  Static generation path rather than obtained through an Engine service.
- The original OpenSpec wording placed EagerSync capture in the maintained-fork
  function-ready callback. That callback occurs before authoritative verified
  route identity exists, so the design/spec now define EagerSync relative to
  the first verified route-ready safe point. The safe point still returns only
  after synchronous compile, validation, and publication.
- Removing the coordinator's transitive BytecodeJIT include exposed two missing
  direct includes, first in ProviderRouter and then in its routing test. The
  failing builds were
  `Saved/Build/jit-coordinator-review-fixes-green/20260814_040851_850_71110974`
  and
  `Saved/Build/jit-coordinator-review-fixes-green-retry/20260814_041219_889_54b4fa29`;
  both consumers now include their actual dependency explicitly.
- An attempted parallel run of three focused automation prefixes demonstrated
  the repository runner's one-command-per-worktree mutex. Editor routing ran,
  while the other two commands were safely rejected and were then rerun
  sequentially. A later outer five-second tool timeout left the already
  launched generated-output child running; its report and metadata completed
  normally with exit code zero, so no second competing run was started.

## Remaining Gate For Group 6

The build and focused test gates above are complete. The narrow read-only
re-review found no Critical, Important, or Minor Group 6 issue and concluded
`READY`. It confirmed closure of the three prior Important findings: Runtime
configuration isolation from Static AOT, task-local Static generator ownership,
and route-ready safe-point semantics. Group 7 must separately close the active
Binding-reader versus Engine-shutdown lifetime risk before the whole change can
be considered merge-ready.
