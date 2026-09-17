# Memory and GC observability research

## Provenance

Read-only inspection on 2026-09-06 in the selected workspace; local installed UE 5.8 source is the version-specific authority. Resolve engine paths from AgentConfig.ini. The workspace is undergoing reconstruction; source presence is not a fresh execution result. `Temp/as的gc.md` is a historical conversation, not a durable runtime contract. No binary or runtime measurement was produced here.

## Current project evidence

Paths start at Plugins/Angelscript/Source/AngelscriptRuntime unless stated otherwise.

| Source/symbol | Observed behavior | Planning implication |
| --- | --- | --- |
| Core/AngelscriptPerformanceStats.h:8,37 | Existing Angelscript Stat group and combined CPU/Stat/CSV timing macro | Reuse the surface and naming convention; existing timers do not provide allocation accounting. |
| Core/AngelscriptMemoryTags.h; .cpp | One Angelscript LLM tag; comment claims gateway coverage | The comment must be corrected against replacement allocation paths. |
| ThirdParty/angelscript/source/as_memory.cpp:176,202 | asAllocMem and SDKAlloc apply the same root tag before FMemory::Malloc | A root tag at the innermost gateway can hide a caller's child tag. |
| ThirdParty/angelscript/source/as_memory.cpp:248-307 | Fresh 64-byte node/instruction allocations and pool returns | Logical return to pool differs from physical free; recheck reachability of each preserved pool before instrumenting it. |
| ThirdParty/angelscript/source/as_vm_object.cpp:21,47 | Direct FMemory allocation includes header, back pointer, payload and alignment slack; AS GC registration is conditional | Track logical payload separately from requested backing bytes. An untagged local path may inherit an outer tag, so verify worker attribution. |
| ThirdParty/angelscript/source/frontend/as_ast_context.h:75 | new T per node and a registered delete callback | Current AST is not a slab arena. Track nodes and owner/container storage honestly. |
| ThirdParty/angelscript/source/frontend/as_frontend_ast_context.cpp:25 | Destroys owned allocations in reverse order | Place lifetime observation at actual creation/destruction, including failure paths. |
| ThirdParty/angelscript/source/as_context.cpp:471 | Releases stack blocks through SDK array deletion | Expose used versus allocated/retained stack storage and suspend/reuse lifecycle. |
| ThirdParty/angelscript/source/as_gc.cpp:75,166,266 | Automatic admission may call phases directly; full/incremental collection; five aggregate GC statistics | Public-call-only timing misses automatic work. CurrentSize is objects, not bytes. Return 1 also covers skipped/unfinished work. |
| Dump/AngelscriptStateSnapshot.cpp:632 | Dumps GC count rows from a script engine | Reuse meanings where valid; do not route replacement snapshots through dormant ambient-engine assumptions. |
| Core/AngelscriptBinds.cpp:1178; ClassGenerator/AngelscriptClassGenerator_Reinstancing.cpp:99 | UObject reference types are NOCOUNT; script references augment UE schema | Separate UE ownership from AS heap and measure bridge work without charging asset graphs to AS. |
| Core/AngelscriptRuntimeModule.cpp:159 | IsLegacyRuntimeEnabled returns false | Profiling must not activate the legacy host to manufacture coverage. |

The VM Change tasks.md:214 records historical 9/9 VMGC success and direct fixture coverage of cycles/weak references. This is evidence of an active AS GC design, not fresh validation of all current code or replacement UE integration. Tests under NewVersion/NativeEngine/VM/VMGCTests.cpp provide useful control workloads; observation tests must consume, not redesign, the collector.

## External sources and version checks

- [Epic Stats overview](https://dev.epicgames.com/documentation/unreal-engine/unreal-engine-stats-system-overview): distinguishes cycle, frame-reset, persistent and memory stats. Use persistent occupancy measures. Local Engine/Source/Runtime/Core/Public/Stats/Stats.h contains the matching declaration macros.
- [Epic LLM documentation](https://dev.epicgames.com/documentation/unreal-engine/using-the-low-level-memory-tracker-in-unreal-engine?lang=en-US): scoped tags attribute native allocations and custom tags can be declared in plugins. Local LowLevelMemTracker.h is authoritative for 5.8 build gates and tag APIs; do not copy outdated compile-flag guidance from prose.
- [Epic Memory Insights](https://dev.epicgames.com/documentation/en-us/unreal-engine/memory-insights-in-unreal-engine): supports allocation lifetimes, callstacks and memory queries. Capture the memory channel from process start; native allocation callstacks do not automatically provide AS source-level stacks.
- [AngelScript GC documentation](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_gc.html): AS's cycle collector supplements reference counting. Registered candidates are not synonymous with all runtime objects or all script-owned bytes.

UE 5.8 local header findings:

- HAL/LowLevelMemTracker.h:16-19 derives ENABLE_LOW_LEVEL_MEM_TRACKER from LLM_ENABLED_IN_CONFIG and PLATFORM_SUPPORTS_LLM; directly defining the derived macro errors. Several older LLM_ALLOW_* macros are deprecated in 5.8. Validate the selected build's actual capabilities rather than promising identical Shipping/Development behavior.
- HAL/LowLevelMemTracker.h:384,437 exposes LLM_SCOPE_BYTAG and custom tags. Hierarchical tags must not cause a parent total plus its children to be added twice.
- ProfilingDebugging/CountersTrace.h defines counters, atomic variants and memory display hints, with COUNTERSTRACE_ENABLED normally depending on tracing and build configuration. A thread-safe counter does not make a multi-field snapshot transactionally consistent.
- Stats/Stats.h exposes memory and persistent accumulator types separately from per-frame counters.

Knot was queried against UE5-main knowledge UUID d890d83194b04c8aad24d0e904cdb762, domain UnrealEngine@UnrealEngine-ue5-main. The first combined query returned no match. A LowLevelMemTracker query returned Engine/Plugins/Runtime/Metasound/Source/MetasoundGraphCore/Public/MetasoundTrace.h, which combines plugin-local CPU trace macros and LLM tag declarations. This is corroborating ue5-main source, not proof of the installed 5.8 version. The primary implementation decisions use the local headers and official pages above.

## Capture routing experiment

Invoked Harness ue.test with PlanOnly=true, Fast=true, the existing Angelscript.UnitTest.NativeEngine.VMGC selector, TimeoutMs=600000, and ExtraArguments containing -LLM, -trace=default,memory,counters and a workspace-local absolute -tracefile path.

Result: Succeeded; Harness envelope RunId 72031c7067f0402ba017fc000ec0c862; planned operation RunId 3a89eee3eed5427d8a4bf47a395affea. The generated UnrealEditor-Cmd argument array contains all three arguments alongside Harness-owned report/log fields. No process was launched, no tests ran and no trace-file content was validated. This establishes that a new Harness route is not currently needed merely to pass capture arguments.

## Verification performed

Source/doc inspection, the capture PlanOnly request, and strict validation of the new Change. Heavier build/Automation/capture runs are omitted because this is a research/record delivery with no product changes. Actual counter correctness, tags, provider decoding and overhead remain future executed acceptance.
