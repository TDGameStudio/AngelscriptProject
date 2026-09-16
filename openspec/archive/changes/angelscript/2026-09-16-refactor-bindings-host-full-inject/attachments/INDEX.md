# INDEX

## Current position

Apply 1.0-5.1 complete. Host prefix Unreal `7d402a23081c410d96ef456210d713f2` 55/55. Specs synced. Ready for completed archive. Knowledges remain change-local candidates.

## Hard conclusions

- First proof after a specific engine binds: `Angelscript.UnitTest.Temp` Prepare/Execute (`TArray` / `FString` / `FVector` / `Print`) plus `AS_BIND_*` / `GetLastSnapshot()`.
- `asCBuilder` compile waits for inject-only. `AddScriptSection` / `CompileModules` are not this path.
- Cache exclusion is `IsCacheV2Enabled() == false`, not a null `GetCacheService()`.
- Capture every registered bind through one seven-phase `ExecuteToHost` and freeze it.
- `BindScriptTypes` and no-arg `CreateForBindings()` inject only; no `ExecuteRegisteredBinds`, no Installation.
- HostScheme keeps S1 / S4-S6. Temp AfterBind* plus HostScheme compile are S2/S3 after inject.
- Old cache tests stay out. Default runtime stays dormant; do not use `Subsystem->GetEngine()`.

## Forbidden

- Do not reopen `host-collect-inject` or treat old 310 RuntimeBindings tests as the green gate.
- Do not treat Host* native-pointer cases or a missing `AS_BIND_*` log as bind-after-engine success.
- Do not restore `AddScriptSection` or editor DirectBinds if a host callback fails; replan instead.
- No links into `openspec/drafts/`, unconfirmed transcript carryover, UHT, disk cache, old cache suites, manifest v2, Insights, or unconditional Quick/Integration.

## Attachment index

- [Accepted design](drafts/design.md) — English export of host-bind-completion; read for Q69-Q78 and architecture.
- [Accepted handoff](drafts/handoff.md) — objectives, exclusions, create authority, carryover.
- [Accepted glossary](drafts/glossary.md) — Change id, HostScheme/HostPerf, inject-only entry.
- [Remaining bind coverage](drafts/findings/remaining-bind-coverage.md) — three current paths and whitelist.
- [Old RuntimeBindings catalog](drafts/findings/old-runtimebindings-catalog.md) — six buckets and dispositions.
- [Verification after host](drafts/findings/verification-after-host.md) — missing compile/call/timing proofs.
- [Verification gates](drafts/findings/verification-gates.md) — S1-S6 / P1-P4.
- [Host test style](drafts/findings/host-test-style.md) — one method per scene.
- [Temp post-bind oracle](drafts/findings/temp-post-bind-oracle.md) — Host* is not bind-after-engine; Temp + logs are.
- [Legacy module compile unavailable](drafts/findings/legacy-module-compile-unavailable.md) — why 1.0 is Prepare/Execute.
- [Host baseline run](data/host-baseline-run.md) — 30/30 Host prefix; no `AS_BIND_*`.
- [Talk: editor inject-only](talks/talk-20260916-074200-editor-inject-only.md) — why replay is rejected.
- [Talk: Store corpus retirement](talks/talk-20260916-074200-store-corpus-retirement.md) — why Store tests are not the gate.
- [Talk: scheme/perf gates](talks/talk-20260916-074200-scheme-perf-gates.md) — why S/P are locked.
- [Talk: Temp post-bind oracle](talks/talk-20260916-161440-temp-post-bind-oracle.md) — why Temp scripts and bind logs are first.
- [Talk: bound-engine call path](talks/talk-20260916-165201-bound-engine-call-path.md) — why Prepare/Execute is 1.0.
- [Knowledge: inject-only BindScriptTypes](knowledges/bindscripttypes-inject-only.md) — candidate — editor entry.
- [Knowledge: scheme/perf gates](knowledges/host-scheme-perf-gates.md) — candidate — completion gates.
- [Knowledge: Host test readability](knowledges/host-test-readability.md) — candidate — test style.
- [Knowledge: Temp post-bind oracle](knowledges/temp-post-bind-oracle.md) — candidate — bound-engine proof.
- [Knowledge: bound-engine call path](knowledges/bound-engine-call-path.md) — candidate — Prepare/Execute until inject compile.
- [Host perf samples](data/host-perf-samples.md) — P1-P4 capture, inject, survival, and Len/opAdd throughput.
- [Planning validation](data/planning-validation.md) — authoring preflight and creation checks.
- [Replan: Temp post-bind oracle](replans/replan-20260916-161440-temp-post-bind-oracle.md) — applied; added 1.0.
- [Replan: bound-engine call path](replans/replan-20260916-165201-bound-engine-call-path.md) — applied; Prepare/Execute oracle.
- [Replan: replay delegate failure](replans/replan-20260916-165900-replay-delegate-failure.md) — applied; 1.0 GREEN is the replay failure.
- [Replan: Temp host surface](replans/replan-20260916-173600-temp-host-surface.md) — applied; 2.1 writes TArray/Log on host.
- `data/closure.yaml` — Completed-closure input for the archive primitive.
- `data/workflow-evaluation.md` — Terminal completed-closure evaluation bound to the current Change digest; write last.
