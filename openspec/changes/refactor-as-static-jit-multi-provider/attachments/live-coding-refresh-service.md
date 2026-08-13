# Explicit Editor Live Coding Refresh

Date: 2026-08-13

## Scope

This attachment records task group 9's explicit Editor-only Generate/Refresh
flow. It does not change save-time behavior and does not add a Live Coding
dependency to Runtime, packaged targets, or generated Provider modules.

The user-facing action is `Tools > Programming > Generate/Refresh AngelScript
JIT`. Ordinary `.as` file watcher notifications continue to queue only the
existing authoritative AngelScript hot-reload transaction.

## Product sequence

One explicit request performs the following bounded sequence:

1. require a current `Source/AngelscriptJIT` scaffold;
2. require the primary Editor AngelScript Engine and its initial compile;
3. force an authoritative full AS source recompile and stop on compile error;
4. build the `EditorDevelopment` Provider output from current project source;
5. atomically publish owned generated files using the existing file store;
6. reject added or removed `Modules/<StableModuleKey>.EditorDevelopment.jit.cpp`
   paths with `RequiresFullBuild`;
7. require the `AngelscriptJIT` UE module and its baseline Provider to be
   loaded, proving that the unchanged source set belongs to an active target
   established by a normal full build;
8. if the expected generation is already present, refresh routes without Live
   Coding;
9. otherwise require Live Coding to be started, enabled, and idle, then request
   one compile;
10. after the patch completes, inspect the live modular-feature view before
    changing the Registry;
11. require a valid ABI/manifest, exact expected ProviderId, a generation
    different from the prior generation and exactly equal to the generated
    expected generation, plus exact artifact-set/profile/native-environment
    identity;
12. only then replace the Registry catalog and publish Engine-local routes.

The pre-registration observation in steps 10-11 is important. A stale,
unexpected, or incompatible patched view must not replace the last copied
Registry generation merely because the view is structurally readable. The
route refresh also rechecks that Registry publication retained the exact
validated generation.

## Why module additions/removals require a full build

Function-body or signature edits within an existing AS module keep the strict
physical source path stable, so Live Coding can rebuild the already known
translation unit. Adding or removing an AS module changes the UBT source graph:

```text
Source/AngelscriptJIT/Private/Generated/Profiles/EditorDevelopment/
  Modules/<StableModuleKey>.EditorDevelopment.jit.cpp
```

The generated file store still writes the authoritative inventory and prunes
only previously owned stale output, but the refresh service does not claim that
Live Coding has discovered a new/removed translation unit. It reports the
exact added and removed arrays, requests a normal full build/restart, and does
not invoke the patch backend. Current script bytecode remains the correctness
path.

## UE 5.8 backend detail

The production Windows adapter uses the Editor-only `LiveCoding` module and
`ILiveCodingModule::Compile(WaitForCompletion, &Result)`. UE 5.8's public patch
delegate has no result payload and is broadcast only along the successful patch
path, while the synchronous result distinguishes success, no changes, failure,
cancellation, an active compile, and failure to start. Waiting is therefore the
only public interface that can classify every required terminal outcome without
guessing from a missing delegate. UE supplies its normal scoped progress UI;
the Editor stays open.

The service itself remains callback-driven behind
`IAngelscriptJITPatchBackend`. Tests retain the completion callback and release
it deterministically, so overlap and every post-patch state are exercised
without starting a real Live Coding process.

## Typed result matrix

The service distinguishes these non-fatal results while preserving VM/current
route correctness:

- Engine unavailable or AS compile failed;
- scaffold required, generation failed, or owned-file publication failed;
- first normal build/provider missing;
- added/removed per-module source set requires a full build;
- Live Coding unavailable, already compiling, or rejected the request;
- no changes, compile failure, patch failure, or cancellation;
- provider missing after patch;
- stale prior generation or an unexpected third generation;
- invalid manifest/ABI, artifact-set, profile, or native environment;
- validated Provider registration/lifetime failure;
- Engine route publication failure;
- already-current generation; and
- successful exact newer generation with Native/VM counts.

Stale/unexpected/incompatible observations are rejected before Registry
replacement. Route publication failure occurs after a validated generation is
copied but the Runtime router fails closed to VM rather than publishing partial
Native state.

## RED/GREEN evidence

Initial RED was an intentionally undefined Editor service. After adding the
test header without an implementation, the Editor target failed at link time:

```text
Saved/Build/staticjit-livecoding-service-red/
  20260813_073326_163_a61fc767
LNK2019: missing FAngelscriptJITRefreshService and patch-backend lifecycle
```

The implemented fake-backend matrix and Editor surface are green:

```text
Saved/Build/staticjit-livecoding-prevalidate-build/
  20260813_074513_665_9e04cc36
Result: Succeeded

Saved/Tests/staticjit-livecoding-prevalidate-tests/
  20260813_074535_933_40166ea4/Report
Totals: total=5 passed=5 failed=0 skipped=0

Saved/Tests/staticjit-livecoding-editor-action-tests/
  20260813_074147_108_550b3465/Report
Totals: total=14 passed=14 failed=0 skipped=0
```

The five CQTest methods contain the full scenario matrix rather than one case
each. The Editor module prefix proves the action is registered and executable,
and its directory-watcher regression proves added/removed/modified `.as` save
notifications never invoke the explicit refresh hook.

## Remaining opt-in smoke

The deterministic state machine, production adapter, generated-source gates,
menu action, pre-registration validation, route refresh, and save-time silence
are implemented. Task 9.4 remains open only for the documented interactive
smoke requiring a user Editor session with Live Coding actually started:

1. change one existing-module function body;
2. observe VM immediately after AS hot reload;
3. invoke `Generate/Refresh AngelScript JIT`;
4. observe the expected new ProviderGeneration and Native route without closing
   the Editor.

A headless `UnrealEditor-Cmd -NullRHI` automation run cannot establish that
external Live Coding session, so it is not misreported as completed evidence.
