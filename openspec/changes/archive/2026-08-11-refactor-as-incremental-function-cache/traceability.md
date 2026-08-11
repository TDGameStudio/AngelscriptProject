# Cache V2 Current Traceability

This matrix connects current normative requirements to the vertical V0–V7
execution plan. Historical task-range mappings are preserved under `history/`.
Normative bytes and behavior remain in the named spec/wire/authority files.

## Requirement-to-checkpoint matrix

| Requirement area | Normative authority | Current checkpoint | Required final evidence |
|---|---|---|---|
| Full-width stable module/type/function/global/property identity | identity delta spec, `identity-golden-vectors.md`, `design.md` | V0 retained; V1/V5/V6 consume | Relocation/two-process/two-engine goldens; no numeric FunctionId persistence. |
| Function source/input/content/profile separation | identity delta spec, `design.md` | V0 retained; V5 integration | Real pre-compiler hit plus clean-vs-cached equality; StaticJIT exact tuple remains independent. |
| Common record envelope/canonical primitives/Budget | record wire and archive vectors | V0 retained; V1/V2 convergence | Sole decoder/factory, cumulative Budget and corruption regression. |
| SourceIndex/ModuleInterface stable DTO/reference semantics | `record-wire-v1.md`, source/interface offsets | V0 retained; V3 production | Direct-input digest, Current candidate validation, exact warm and additions/deletions. |
| TypeSchema/ModuleState/FunctionBody/DebugSidecar/ModuleSnapshot | remaining-record wire, type/module matrices | V1 | Complete in-memory clean module transaction through one factory/graph. |
| TypeSchema local/hash/layout/dependency correctness | type layout/schema authorities | V1 active | Focused family files plus complete selected-module decoder/graph regression. |
| Private VM artifact validation and attachment | incremental delta spec, `design.md` | V1 codec boundary; V5 attach | Corruption before mutation and forced-clean versus restored parity. |
| ModuleSnapshot atomic graph/activation | incremental delta spec | V1 graph; V3/V6 activation | No partial output/mutation; complete module transaction only. |
| Pack/Manifest deterministic bytes and reachability | manifest/pack wire/RED authority | V2 | Serial/order determinism, exact reachability, codec/corruption tests. |
| Saved-only immutable Store and roots | `store-publication-v1.md` | V2 | Fault/cancel/concurrency old-or-new root evidence and pinned sessions. |
| Direct inputs versus preprocess-derived candidates | source delta spec, `design.md`, vertical decision | V3 | Lookup validates bounded candidate without rerunning preprocessor. |
| Exact unchanged zero-work restore | incremental delta spec | V3 | Cold then fresh warm with zero preprocess/parse/compiler counters. |
| Changed-module semantic classification and incremental publication | invalidation delta spec | V4 | Full clean compile; semantic RecordId comparison for body/type/state/debug cases. |
| Typed dependency propagation | invalidation delta spec, matrices | V4/V5 | Minimum proven closure or conservative miss; no text-diff semantic oracle. |
| Per-function compiler reuse | identity/incremental delta specs | V5 | All invocation kinds categorized; actual dependency capture; real compiler hits. |
| Engine mutation serialization/publication DTO | lifecycle delta spec | V6.1–V6.4 implemented | Two-engine/cancel/shutdown/lifecycle tests plus immutable per-Engine route publication and failed-reload last-good identity. |
| Editor HotReload and PIE structural policy | lifecycle delta spec | V6; V7 real PIE | Current/Pending/last-good/reinstancing evidence. |
| Stable FunctionId/Native-VM route reconstruction | identity and lifecycle delta specs | V6.4 plus V7.4 lifecycle correction | `AngelscriptCacheRestore`, clean-capture validated identity handoff and StableSymbolIdentity authority; route refresh never formats retained functions through replaced dependency type metadata. FunctionRouteSnapshot `4/4`, HotReload Dependency `2/2`, complete HotReload `122/122`, complete Cache `495/495`. |
| Cache/StaticJIT isolation seam | identity delta spec, sibling change | V6.5 plus V7.4 affected acceptance | Cache-owned safe-point refresh with injected selected/miss/departure/failure outcomes leaves the exact Current/Pending/LatestSuccessful publications and VM artifacts intact; StaticJITIsolation `3/3`, DecisionTrace `3/3`, and the dedicated generated-AOT StaticJIT workflow `30/30`. Actual provider ABI/catalog matching and Live Coding state machine remain sibling evidence. |
| Legacy removal and loose NonUFS package source | packaging delta spec, proposal | V7.1-V7.3 implemented | LegacyCutover `4/4`; production old reader/writer/generator/forced-exit and package pre-step absent; loose-layout helper self-tests and Development/Shipping `CachePackage` dry run pass. Real archive inspection remains V7.6. |
| Real PIE and Development/Shipping multi-launch | packaging/lifecycle specs | V7 last | Cold/warm/edit/invalid/restored/structural executable reports. |
| Diagnostics, Pack policy and performance | diagnostics delta spec, benchmark plan | V6 plus V7.3 process report | C++ shutdown emits `-as-cache-report` stable JSON for live Engine evidence; Python consumes/diffs persisted Store. SettingsAndShutdown `3/3`; raw 4/16/64 MiB/cold/warm/edit results remain V7.7. |

## Public outcome trace

| Public/product outcome | First executable checkpoint | Final proving checkpoint |
|---|---|---|
| Stable functions survive restarts, HotReload and numeric FunctionId changes | V1 | V5/V6/V7 |
| First launch creates Cache V2 during normal execution | V2 | V7 Shipping/Development |
| Unchanged launch performs zero preprocess/parse/compiler work | V3 | V7 multi-launch |
| Changed module retains unchanged semantic records | V4 | V7 edit scenarios |
| Changed module obtains true per-function compiler hits | V5 | V6/V7 parity/integration |
| Class/global changes remain module/lifecycle safe | V4 | V6/V7 |
| Editor/PIE maintain the same Cache V2 | V6 | V7 real PIE |
| StaticJIT selects Native per stable function without owning Cache freshness | V6 | V7 affected StaticJIT/package evidence |
| No `PrecompiledScript.Cache` production dependency remains | V7 | V7 final classification |

## Safety ownership trace

| Safety property | Owner | No-shortcut rule |
|---|---|---|
| Stable identity and collision behavior | V0/shared identity | Full 256-bit values; display GUID is never authoritative. |
| Record errors, offsets, allocation and ownership | V1 | One decoder/factory/promotion; tests observe the same path. |
| Private VM bytes | V1/V5 | Private codec validates complete state; no raw bytecode attach. |
| Module graph and activation | V1/V3/V6 | Granular persistence never permits partial module mutation. |
| Pack/Manifest/Store publication | V2 | Immutable content first, manifest next, root last; no delete-then-move. |
| Source authority | V3/V4 | Direct input/candidate mismatch enters authoritative frontend; no stale-source fallback. |
| Compiler reuse | V5 | Declarations/layouts first; unsupported state is Miss/NotCacheable. |
| Concurrency | V2/V6 | Workers consume immutable DTOs; each engine owns one mutation gate. |
| StaticJIT | V6/sibling change | Provider state changes routes only; Pack/Generation IDs never match Native entries. |

## Final closure chain

```text
V0 strict OpenSpec reset
  -> V1 complete in-memory real-module transaction
  -> V2 cold generation publication/reopen
  -> V3 exact warm zero-work restore
  -> V4 changed-module clean oracle/incremental publication
  -> V5 real per-function compiler hits and parity
  -> V6 focused lifecycle/StaticJIT isolation
  -> V7 real PIE and Development/Shipping multi-launch
  -> V7 benchmark/docs/archive
```

Pure V2 data-plane work may be implemented while remaining V1 negative families
are completed, but downstream activation cannot retroactively close an unproven
record/graph/private-codec boundary. Any normative change updates its owning
authority and explicitly invalidates affected frozen evidence.
