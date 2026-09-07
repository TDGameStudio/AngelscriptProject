# Recommended metrics and probes

This matrix carries the research handoff. proposal.md owns the intended behavior. The names below are proposed labels, not existing commands/APIs or evidence of implementation. Complete concrete types, file owners and lifecycle contracts in design before product work.

## Accounting dimensions

| Measure | Definition | Do not confuse with |
| --- | --- | --- |
| LiveObjects | Successfully constructed/owned logical instances in the selected domain, with construction-in-progress separate where needed | Heap allocation count or GC candidate count |
| LiveAllocationBlocks | Successful backing allocations not physically freed, where exact gateway coverage exists | Objects, members or pool slots |
| LiveRequestedBytes | Sum of requested bytes for live, uniquely owned covered backing allocations | Process RSS, allocator committed memory, or sum of sizeof for objects with dynamic storage |
| PayloadBytes | Known object payload only | VM header/alignment or referenced asset memory |
| AllocatedTotal / FreedTotal | Monotonic successful backing-allocation/free events within a counter epoch | Per-frame values or logical pool acquire/return |
| ObservedPeakBytes | Maximum sampled or continuously maintained occupancy, explicitly labeled by method/window | A historical process peak when observation began late |
| ReservedBytes / UsedBytes | Owner-measured capacity and used capacity for an actual pool/buffer | Another additive copy of the same backing bytes |
| GCTrackedObjects | Objects enrolled in the AS collector | All AS objects or all UObjects |
| PhaseWorkItems | Explicit iterations/visits/edges under the chosen phase contract | Unique objects reclaimed |
| GCReleasedPayloadBytes | Payload of known AS allocations actually freed in collection-associated cleanup | Physical OS memory reclaimed or a GC candidate-count delta |
| RetiredRetainedBytes | Unique covered storage still owned by retired-but-live generations | Automatic proof of a leak |

Report the covered set and allocator basis. RequestedBytes is unavailable for uninstrumented gateway families, not a guessed zero. Shared storage contributes once to the total, with non-additive consumer references available separately. Do not sum payload plus its backing block, or a pool's slots plus its reservation, into one total.

## Categories and insertion points

Proposed bounded LLM hierarchy: Angelscript/Frontend, TypesMetadata, Bytecode, VMObjects, Contexts, GC, RuntimeSupport, Diagnostics, SDKOther. Use actual 5.8 declaration syntax and parent fields. No per-object or unbounded per-module tags.

| Owner | Logical observations | Physical attribution / lifetime probes |
| --- | --- | --- |
| Source/frontend | snapshots, AST nodes, compilation sessions, retained source bytes | source snapshot construction, AST new/delete, token/container growth, compilation worker entry |
| Types/metadata | type/definition/image counts, shared registry and generation ownership | type context, metadata image and identity-container allocation/destruction |
| Executable images/bindings | instruction/data bytes and live/retired image counts | image build/decode/link, container capacity, final owner release |
| VM objects | live count, payload/header/requested storage, normal release vs collection attribution | asVmAllocateObject/asVmFreeObject, asVmRelease, construction rollback |
| Contexts | active/prepared/suspended counts, stack used/reserved bytes | context create/destroy, stack grow/reuse/release, suspend/abort |
| AS GC | candidate lists, map/cached-node storage, attempts, phases, actual destruction | GC admission, automatic phase path, full/incremental path, free callbacks |
| Runtime support | actual function/delegate/capture and reusable storage owners | published lifetime/dispatch owners; absent future closure layouts stay unavailable |
| UE bridge | known script UObject/CDO counts and schema/collection work where supported | existing replacement host lifecycle/UE tracing; no second heap total |
| Diagnostics | observation buffers, bounded registries and snapshot buffers | dedicated attribution so tooling overhead is visible |

SDK allocation scopes must preserve the selected AS category. Avoid placing SDKOther unconditionally on top of a specific owner scope. Worker allocations cannot rely solely on a tag pushed by the thread that queued the work. Audit native callback boundaries to avoid charging unrelated engine allocations to AS.

## Publication contract

Produce one versioned snapshot with timestamp/epoch, scope (process/engine/generation), consistency marker, coverage and profiler capability flags. Fixed aggregate metrics use 64-bit accounting, explicit units and bounded cardinality. Stats/Trace/CSV exporters consume the same sample; they do not independently mutate allocation counters. On-demand detail may walk owner state only at a supported safe point.

Use zero-allocation lifecycle hooks, bounded atomic/owner-local state, and a serialized publication point for ordered counter samples. Guard against recursion from diagnostic allocation, reentrant collector calls and teardown after the observer's owner disappears. Free attribution survives thread changes without retaining a runtime object solely for observation.

## GC event contract

Expose attempt ID, collector/engine ID, trigger (explicit/automatic/shutdown), mode/flags, requested iterations, entered/skipped outcome, phase timings, work counts and actual destroyed/freed metrics. Internal automatic work needs observation even when the public GarbageCollect entry was not called. A skipped reentrant attempt must not add phase work or a completed cycle.

Report new/old candidate occupancy and counter deltas as observations, not a promise every candidate is garbage. Record whole-cycle and incremental phase relationships without counting nested scope times twice. Do not add a scheduler or change full/incremental work limits in this observability Change.

## Independent proving examples

- Allocate covered buffers of 64 and 128 requested bytes: live requested=192 and two blocks. Free the 64-byte block: live=128 and one block, allocated total=2, freed total=1. Final free returns to baseline; failure adds no successful live allocation. Reallocation grow/shrink/failure has a predeclared event convention and preserves arithmetic.
- A VM payload and its header/alignment produce separate payload/backing values; destruction changes logical and physical measures exactly at their owning transitions.
- A pool with four 64-byte slots has 256 backing bytes. Returning one occupied slot reduces used capacity by 64 but leaves backing unchanged. Reuse adds a logical acquire without a new backing allocation; trimming physically releases the relevant backing allocation.
- Allocate on a compilation worker and release on another thread after owner retirement. The original category is retained; final unique totals return to baseline. Two contexts referencing one image count its storage once until the last owner releases it.
- A rooted two-node cycle survives a collection and is freed once per node after root release. Full and incremental execution converge on the same destruction set, although phase-work counts need not match. Observe an automatic admission-triggered collection and a reentrant skipped attempt as distinct cases.
- A suspended context or retained generation keeps its legitimate storage visible. It returns to baseline after release/abort; the observer itself does not retain it.
- Export the same known snapshot to Stats/Trace/structured output and compare values/units. A profiler-disabled configuration reports availability correctly and does not change collector results or object lifetimes.
- Capture an actual trace with a distinctive covered allocation and GC workload; check native memory events, tag/category, counters and CPU phase spans in their actual providers. Macro presence and PlanOnly do not satisfy this test. Validate the stat panel separately when a rendered session is needed.
- Measure disabled/basic/detailed modes on the same bounded workload, reporting repeated samples and instrumentation storage. Fix an acceptance threshold in the implementation plan before measuring; do not infer zero overhead from disabled macros or choose a threshold after results.

## Capture preparation

The following is a supported planning shape, not an instruction to run product tests during record creation:

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
$asTracePath = Join-Path (Get-Location).Path ('Saved/Profiling/Angelscript-' + [guid]::NewGuid().ToString('N') + '.utrace')
Invoke-Harness -Command ue.test -Context $context -Parameters @{
    TestPrefix = 'Angelscript.UnitTest.NativeEngine.VMGC'
    PlanOnly = $true
    Fast = $true
    TimeoutMs = 600000
    ExtraArguments = @('-LLM', '-trace=default,memory,counters', ('-tracefile=' + $asTracePath))
}
```

For future execution, select the real instrumentation fixture, ensure the trace parent exists, use the matching freshly built binary, and keep a unique path. Capture memory from startup. Additional metadata/assetmetadata channels are optional for a demonstrated UE asset/class investigation; AS generation detail requires its own supported semantic correlation. Archive only a trimmed result summary and trace provenance under the Change, leaving raw traces in ignored Saved. Inspect actual engine build gates, symbols and provider data before declaring capture successful.
