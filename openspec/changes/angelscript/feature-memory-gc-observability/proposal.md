## Why

The user needs to see what AngelScript allocates, how much remains alive, what is retained for reuse or by old generations, and what GC processes and releases in each batch. The request's wording about batches is interpreted as covering both allocation/free accounting and incremental GC/pool work. The later accepted `angelscript/refactor-sdk-drop-native-gc` Change removes the AS cycle collector. It is still pending, so collector code is present today; this observation plan targets the accepted post-removal lifetime model and must not add a dependency on the retiring collector.

Existing evidence cannot answer these questions consistently:

- Preserved UObject integration disables AS automatic collection and publishes script-held UObject references to UE GC, while the replacement VM allocates its own non-UObject heap and currently still contains AS cycle collection pending that removal. The target observes refcount release and shutdown drain separately from UE GC.
- The plugin already has STATGROUP_Angelscript, CPU/CSV timing scopes, a single Angelscript LLM tag and GC counts in legacy-oriented dumps. These are useful foundations, not comprehensive replacement-runtime accounting.
- The SDK gateway is tagged, but asVmAllocateObject uses FMemory directly and replacement AST nodes use ordinary new. The comment that all AS allocations pass through SDKAlloc/asAllocMem no longer describes all allocation paths. Actual tagging can also depend on an outer scope and worker thread.
- Object counts are not byte counts; freeing an object into a pool is not releasing its backing memory; GC work iterations are not unique object visits; a retained metadata generation is not automatically a leak. A single number named AS memory or GC count obscures these distinctions.

The outcome is a measured ownership inventory and consistent Unreal-native profiling views, without changing allocation semantics, GC policy or the dormant legacy baseline.

## What Changes

### One observation model with Unreal-native outputs

Use ownership-bound instrumentation and a bounded snapshot model to feed existing UE tools:

| Surface | Purpose | Intended implementation direction |
| --- | --- | --- |
| stat Angelscript | Live summary of logical memory, object counts and collection work | Extend the existing group with persistent gauges, memory counters and selected cycle timers. Do not use frame-reset counters for live occupancy. |
| LLM / stat LLMFULL | Allocator-level live bytes attributed to AS categories | Extend the existing Angelscript tag with bounded child tags; repair allocation and worker attribution. Use plugin APIs, not engine patches. |
| Unreal Insights counters and CPU events | Time series and allocation/compile/GC/reload correlation | Publish the same snapshot through CountersTrace and existing timing conventions, with bounded phase names. |
| Memory Insights | Real heap allocation/free history, callstacks and retained blocks | Consume UE's native memory tracing. Do not duplicate FMemory events as manual allocations on the same heap. |
| Explicit diagnostic snapshot | Reproducible per-engine/generation detail and before/after comparison | Provide a replacement-safe snapshot, independent of an ambient legacy engine, with numeric units, coverage and provenance. |

The canonical logical counters and UE's allocator accounting describe different measures. Export their basis explicitly; do not require logical payload bytes to equal LLM, allocator-rounded size or process resident memory.

### Ownership and category coverage

Inventory allocation and release paths before claiming coverage. The first implementation covers maintained replacement paths for source/frontend nodes and buffers, shared publication/type-identity records, unique DefinitionSet/Engine metadata and executable storage and runtime bindings, VM objects, contexts/stacks, VM shutdown bookkeeping, function/delegate runtime ownership, reusable storage and diagnostic instrumentation. Use a bounded category set, with an explicit SDK/Other fallback rather than silently dropping uncategorized allocations.

Each inventory row identifies the owner, allocating/freeing functions, whether storage is shared or pooled, its thread/lifetime boundaries, physical allocation gateway, logical-count producer and intended LLM scope. Current AST nodes are individually allocated; do not label them an existing arena or report arena capacity unless a real arena is present.

UObject instances, script-added UObject storage and script-held references are a separate host view. Their memory and reachability remain owned by UE. Do not add the transitive size of referenced textures/meshes/assets to AS heap totals. Distinguish strong, weak and soft references where supported; lack of UPROPERTY exposure does not eliminate GC visibility requirements.

### Metric semantics

The initial metric contract includes:

- live logical object counts by bounded category; cumulative allocations/frees and interval deltas;
- known requested live bytes and observed peak, with the peak window identified;
- backing/reserved bytes and used/free capacity only for actual pools or containers whose owners can measure them; allocator-rounded and OS-committed bytes remain distinct;
- active and retired-but-retained generation/image counts and owned storage, without counting a shared allocation once for every consumer;
- native VM allocation, final-release destruction, retained cycles and shutdown-drain work, with payload death distinct from backing release;
- UE GC/schema observations only where replacement host APIs exist; native cycle-collector metrics are explicitly unavailable after removal;
- availability/coverage flags for each metric and profiler mode. Disabled, unsupported or partial observation is not presented as an authoritative zero.

Physical frees and logical destruction are different events. Record actual successful transitions; do not infer GC bytes freed from before/after candidate counts, which can include concurrent allocation, resurrection or retained storage. GC freed payload bytes cover only known AS-owned storage and must not be advertised as process memory returned to the OS.

### Lifetime observation after the accepted native-collector removal

Observe native VM allocation, final release and shutdown drain. An unrooted cycle is retained while its Engine lives under the accepted removal design; report that retained storage without claiming runtime reclamation. The removal owner must first prove the drain mechanism and externally retained-object contract. Full/incremental/automatic AS collector instrumentation is outside the target.

Keep UE GC timing and reference-schema construction separate. Observe actual UE GC boundaries through supported facilities when that replacement host path exists, and report unavailable/dormant probes honestly. Replaced `_REPLACED_N` UClass tombstones are distinct retained host metadata, as recorded by `docs-class-reload-replaced-tombstone-lifetime`; memory reporting does not authorize unrooting or destroying them.

Historical collector measurements remain September 6 research evidence. A removed metric reports unavailable, never a fabricated zero. This Change implements no collector deletion or alternative collection policy.

### Attribution and overhead boundaries

- Use bounded stable LLM/Stat/counter names. Per-type, per-module and per-generation drilldown belongs in explicit snapshots or bounded diagnostic trace records, not an unbounded dynamic stat registry.
- Ensure a generic SDK allocation tag does not mask a more specific owner tag at the top of the LLM stack. Preserve an AS category through owned allocation operations and asynchronous entry points; native callbacks and unrelated engine work must not all be charged to the VM by an excessively broad scope.
- Store enough ownership information to account for frees on a different thread or after the producer/session has retired. Observer metadata must not keep the object, UObject or generation alive merely to display it.
- Counters at allocation/destruction boundaries must not allocate, stringify labels or take a contended global reporting lock. Aggregate in bounded owner/thread state and publish coherent snapshots at safe points; avoid traversing mutable owner/drain state from a rendering/stat thread.
- Keep exact per-owner quiescent snapshots for tests and on-demand diagnosis. Mark rolling concurrent samples with their consistency scope; do not imply individually atomic fields form a transactionally exact process snapshot.
- Reuse native FMemory tracing and LLM. Do not install a second global allocator or call manual LLM/MemoryTrace allocation events for memory already observed by UE. Custom suballocation tracing is a separate opt-in extension only if real pools require it and UE heap APIs are verified.
- Gate Stats, LLM and trace outputs against the actual target's UE 5.8 feature defines. The default mode uses bounded aggregate counters; detailed memory callstacks/trace records are opt-in. Measure disabled/basic/detailed overhead before claiming it negligible.

### Intended user workflow

Users inspect the current AS totals through stat Angelscript, inspect category allocation with stat LLMFULL when LLM is enabled, and capture Unreal Insights from process launch with memory and counters channels for detailed analysis. CPU scopes correlate compile, execution, collection and retirement. Memory callstacks locate C++ allocation sites; source-level AS callstacks are not automatically provided by native memory tracing.

Future capture runs use Harness ue.* with ExtraArguments. A PlanOnly test request has already accepted -LLM, -trace=default,memory,counters and an explicit workspace trace file. That proves argument routing only, not successful tracing or instrumentation coverage. Real captures require a matching build, executed fixture, nonempty trace, symbols as applicable, and verified data providers. Headless tests prove instrumentation data; they do not by themselves prove the on-screen stat panel.

## Capabilities

### New Capabilities

- `angelscript/runtime/memory-observability`: Ownership inventory, metric definitions, bounded snapshots, allocation/lifetime/GC correlation and Unreal profiling outputs.

### Modified Capabilities

No existing durable requirement is intentionally relaxed at creation. Runtime startup dormancy, AST ownership and type/generation lifetime are preserved. During design, add deltas to an existing capability only when its actual behavior contract changes; GC algorithm work remains with its runtime owner.

## Impact

- Parent repository: this Change, later durable specs, indexed evidence, and capture/verification guidance. No production change is made during this research delivery.
- Plugins/Angelscript: existing Core/AngelscriptPerformanceStats and AngelscriptMemoryTags; maintained SDK memory/VM/GC/context paths; frontend/type/metadata/image owners; replacement-safe snapshot export; replacement tests in Source/AngelscriptTest/NewVersion.
- Existing Changes: consume refactor-vm-symbolic-execution ownership and evidence; keep delegate capture policy and constructor/default migration separate. Do not change their tasks or assume planned services are already available.
- Keep Source/AngelscriptProject minimal. Existing Harness ExtraArguments support is sufficient for capture planning; no engine patch or new Harness route is justified by current evidence.

### Alternatives and decision

Stats alone gives a cheap overview but cannot explain allocation lifetimes or callstacks. A replacement global allocator/address registry duplicates UE tracing, misses semantic lifetime and increases overhead. Select ownership-bound counters plus LLM/native Memory Insights and CPU tracing. Add a custom detailed allocator stream only if a demonstrated allocation family remains invisible after correct native attribution.

### Non-goals

Removing AS GC, changing ownership semantics, adding a collector scheduler or hard per-frame budget, memory quotas/automatic trimming, leak-proof claims based on one snapshot, reactivating legacy runtime, shipping always-on per-allocation stack capture, a custom Insights UI/analyzer, or a universal whole-process memory total attributed to AS.

### Acceptance direction

Prove balanced allocation/free and rollback, independent logical-versus-physical pool behavior, attribution across workers, no double counting of shared owners or UObjects, native final-release/shutdown-drain observations and explicitly unavailable retired-collector metrics, correct late retirement, unavailable-state reporting and agreement between snapshot/Stats/Trace for the same sample. Validate actual LLM/Memory Insights events in a captured session, not only macro presence. Use an explicit bounded workload to measure instrumentation overhead.

The creation delivery contains the proposal, research/metric attachments and a pending planning task required by the workflow. Design, durable scenarios and exact implementation cards remain to be authored. It is not implementation-ready and does not claim measured memory sizes, a passing current GC suite or a captured .utrace file.
