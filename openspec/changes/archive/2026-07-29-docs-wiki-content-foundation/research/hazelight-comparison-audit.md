# Hazelight Comparison Audit Framework

Captured: 2026-07-25

This note defines how the future Wiki compares this standalone plugin with Hazelight's engine-integrated AngelScript fork. It is a documentation research record, not an instruction to synchronize code and not a finding that any upstream change should be adopted.

## Compared baselines

| Side | Revision used for this research | Role | Important boundary |
|---|---|---|---|
| Hazelight source | private `Hazelight/UnrealEngine-Angelscript`, branch `angelscript-master`, `f459e6322f63deef8d345f1c1624734cc22747e3` | Current source-level reference | The source cannot be bundled into the public Wiki without a separate authorization and license review. |
| Previous Hazelight audit marker | `138a7e186082b639375b95545e0177b18f13c4be` | Distinguishes the one new upstream commit seen during this research | This OpenSpec does not advance `.agents/skills/hazelight-update-audit/references/audit-state.json`. |
| Local plugin | published/committed tree at `4e2e23ca16ae9f1786258fb96b09b268259b1aad` | Stable local comparison source | The current plugin worktree is dirty and is not evidence for a reproducible Wiki snapshot. |
| Historical engine-path report | `Documents/Hazelight/HazelightAngelscriptEngineChangeReport.txt`, generated 2026-03-12 | Path-level evidence that Hazelight modified engine files | It has no Git revisions and exposes only the leaf rows visible in the folder-comparison report. |
| Local explanatory notes | `Documents/Hazelight/*.md`, `Documents/Knowledges/ZH/Diff_Hazelight*.md`, syntax notes, archived OpenSpecs | Research leads and historical decisions | Claims must be rechecked against the two pinned source revisions before publication. |
| Hazelight public docs | `Reference/Docs-UnrealEngine-Angelscript` | User-visible behavior and terminology | Public docs cannot prove source parity, implementation shape, or current private-branch behavior. |

The future Wiki must show both revisions and the comparison date. “Hazelight” without a revision is too ambiguous because its engine branch, plugin code, Unreal baseline, and public documentation can move independently.

At capture time, `AgentConfig.ini` contained both engine keys, but `References.HazelightAngelscriptEngineRoot` and `Paths.EngineRoot` resolved to the same directory. That configuration therefore could not serve as a two-sided source comparison and was not used to infer semantic differences. The authorized pinned private remote source supplied the current Hazelight side; the configuration problem should be fixed or explicitly waived before a later local folder audit.

## Evidence priority and confidence

Comparison statements use the following evidence order:

1. Pinned source from both sides, with symbols or bounded line excerpts.
2. Pinned commit patches and source-owned tests.
3. Reproducible build, test, state-dump, or benchmark output.
4. The dated engine-path report and local research notes.
5. Public Hazelight documentation.
6. Inference, which must be labelled and must not be presented as verified behavior.

Each comparison row records:

- `hazelight-revision` and `local-revision`;
- `compared-on`;
- `relationship`;
- evidence keys for both sides;
- `confidence: verified | supported | provisional`;
- Unreal-version applicability;
- user-visible consequence;
- maintenance consequence;
- adoption disposition when relevant;
- an explicit benchmark field when a performance claim is made.

The relationship vocabulary is:

- `same` — verified equivalent behavior and compatible mechanism for the stated scope;
- `diverged` — both exist but intentionally differ in behavior or architecture;
- `selective-backport` — a bounded Hazelight behavior was absorbed without taking the whole implementation;
- `reimplemented` — the local fork provides the outcome through a materially different mechanism;
- `removed` — a historical Hazelight/Haze-specific path was deliberately removed locally;
- `local-only` — the local fork has a capability not found in the compared Hazelight revision;
- `future-candidate` — evidence indicates a possible gap, but no adoption decision is made.

“Missing” is not a relationship by itself. The author must first determine whether the capability is absent, intentionally unnecessary, packaged elsewhere, replaced by stock Unreal behavior, or still unverified.

## Initial seven-page Hazelight topic

| Logical key | Depth | Required reader outcome | Minimum evidence |
|---|---|---|---|
| `reference-differences-version/hazelight-comparison-overview` | L0 | Understand what is being compared, which revisions apply, and why engine-fork and standalone-plugin constraints differ. | Baseline table, evidence legend, relationship legend. |
| `reference-differences-version/hazelight-capability-matrix` | L2 | Find a feature family and see its current relationship without treating the matrix as an adoption backlog. | Revisioned rows, owner topic, consequence, links to detailed pages. |
| `reference-differences-version/hazelight-function-binding` | L4 | Trace how native UFunctions become callable AS functions on both sides. | UHT/generator input, eligibility, pointer or fallback artifact, runtime registration, call convention, unsupported cases, tests. |
| `reference-differences-version/hazelight-class-generation` | L4 | Trace class declaration, UClass/UFunction representation, defaults/CDO construction, dispatch, reload, and editor-only behavior. | Engine and plugin hooks, generated types, call path, reload path, regression evidence. |
| `reference-differences-version/hazelight-struct-generation` | L4 | Trace UScriptStruct/UASStruct creation, `ICppStructOps`, lifetime operations, serialization, reload, and engine-version coupling. | Current interface signatures, ops ownership, deterministic lifetime tests, engine-patch boundary. |
| `reference-differences-version/hazelight-architecture-differences` | L4 | Understand the consequences of modifying Unreal versus keeping the integration plugin-contained. | Module graph, engine-file patch families, optional-plugin boundaries, upgrade/packaging implications. |
| `reference-differences-version/hazelight-audit-maintenance` | L5 | Repeat the comparison without silently changing its baseline or copying private source into the Wiki. | Audit command/workflow, source registry rules, stale detection, change history. |

The capability matrix reserves later rows for language features, preprocessor/compiler/kernel changes, hot reload, editor/debugger, testing, coverage, examples, domain integrations, removed Haze behavior, and local-only facilities. A reserved row is not a requirement to create an empty article.

## Detailed findings to seed the pages

### Function binding and UHT

Hazelight uses an engine-integrated path:

1. Its modified `EpicGames.UHT` reconstructs the original C++ signature.
2. `GetASFunctionPointers` emits `ERASE_FUNCTION_PTR`, `ERASE_METHOD_PTR`, or `ERASE_NO_FUNCTION`.
3. generated native-function records carry `ASFunctionPointers`;
4. `UClass::ASReflectedFunctionPointers` exposes the records at runtime;
5. `Bind_BlueprintCallable.cpp` rejects entries without a caller, recovers static or member function pointers, and registers the AS method/global/mixin with the appropriate calling convention;
6. `UClass::GetFunctionMap()` lets binding discovery enumerate the otherwise private function map directly.

The current Hazelight generator explicitly declines custom thunks and native-interface cases and can decline signatures whose original declaration cannot be reconstructed. Those cases are evidence that “generated binding” is policy-limited rather than universal.

The local fork has reimplemented this area around a standalone `AngelscriptUHTTool` C# UBT plugin:

- `NativeRuntimeLinked` emits generated shards linked through configured Runtime dependencies;
- `NativeModuleFunctionAddress` emits target-module shards and publishes a versioned POD payload through `IModularFeatures`; it requires a source engine;
- `BlueprintCallableReflectiveFallback` covers safe reflective calls and is mandatory for RPC/Net UFunctions so Unreal routing is not bypassed;
- policy rejects or defers unsafe cross-module signatures such as unsupported out/ref/container/world-context forms;
- statistics, per-module CSV data, diagnostics, cleanup, and layout-version checks make the output auditable.

The initial relationship is `reimplemented` with deliberate `diverged` subpaths. The detailed page must compare eligibility and fallback behavior, not only the fast-path call instruction.

### Class generation

The current Hazelight design is hybrid rather than simply “everything lives in UClass”:

- engine `UClass` carries generic AngelScript fields and hooks such as `ASReflectedFunctionPointers`, `ScriptTypePtr`, `bIsScriptClass`, runtime object lifecycle virtuals, and direct function-map access;
- engine `UFunction` carries runtime call/event/validation hooks and `FUNC_RuntimeGenerated`;
- engine `ScriptCore.cpp`, `UObjectGlobals.cpp`, editor code, and Actor code recognize runtime-generated script types;
- plugin `UASClass` still owns script-specific class state and behavior.

The local fork keeps the integration plugin-contained:

- `UASClass : UClass`, `UASFunction : UFunction`, and their specialized dispatch classes own script state;
- generated script UFunctions use the stock native-function route and plugin thunk instead of adding `FUNC_RuntimeGenerated` to Unreal;
- object construction uses stock public hooks such as `ClassConstructor`;
- reference, default-component, reload, and reinstancing behavior is implemented in plugin Runtime/Editor sources.

Therefore the architectural relationship is `reimplemented`, with some shared concepts and different Unreal patch/ABI costs. The page must not repeat the older shorthand “Hazelight uses UClass, local uses UASClass” because Hazelight also has `UASClass`.

The current upstream delta `f459e6322f63deef8d345f1c1624734cc22747e3` adds type-level editor-only propagation: editor-only modules mark class/struct descriptors, generated `UASClass`/`UASStruct` instances store that state, and `IsEditorOnly()` reports it. The committed local revision has editor-only handling for functions, properties, components, and binding filters, but the same type-level fields/overrides were not found. This is a `future-candidate` finding for a separate code OpenSpec, not work authorized by this documentation change.

### Struct generation

Both sides create a `UASStruct` and bridge script-defined value lifetime into Unreal `UScriptStruct` operations. The important difference is where the required context is supplied:

- Hazelight modifies Unreal's `ICppStructOps` fake-vtable path and passes an ops/self context through construction, destruction, copy, identical, export, hash, and related calls;
- the local fork implements `FASStructOps` and `UASStruct` against the stock-engine interface and adapts its context/lifetime ownership inside the plugin.

This comparison is especially version-sensitive: stock Unreal fake-vtable signatures have changed across engine updates. Every published struct claim must state the UE version, show the current signatures on both sides, and cite lifetime/serialization/hot-reload tests. The blanket historical claim that one approach is always unnecessary is too broad to publish without that revalidation.

### Architecture and module ownership

At the compared revisions:

- Hazelight's plugin declares `AngelscriptCode`, `AngelscriptEditor`, and `AngelscriptLoader`, while its integration also depends on Unreal source changes.
- The local plugin declares `AngelscriptRuntime`, `AngelscriptEditor`, and `AngelscriptTest`, has the independent C# `AngelscriptUHTTool`, and keeps GameplayTags/GAS integration in optional plugins.
- Hazelight currently has 112 `Binds/Bind_*.cpp` files in `AngelscriptCode`; the local committed Runtime has 121. Counts are revisioned inventory data, not a quality score.
- Hazelight keeps `Bind_FGameplayTag.cpp` in the core plugin, whereas the local fork's GameplayTags behavior is owned by `AngelscriptGameplayTags`.

The architecture page must distinguish source layout, packaging boundary, behavior, and test coverage. A different file count or module name does not prove feature parity.

## Known stale or conflicting local notes

The following items are research debt and publication blockers:

- `ScriptClassImplementation.md` links to `UEAS2-UHT-Modifications-Analysis.md`, but that file is not present.
- Its “22 C++ + 11 C# files” statement is not reconciled with the dated folder report, which visibly lists only 13 changed `Engine/Source` leaf files and omits current verified private/editor/UHT changes.
- Nanosecond-level and “same/no significant difference” performance statements in historical class notes are estimates unless a pinned benchmark artifact exists.
- `ScriptStructImplementation.md` contains useful mechanism research but makes an engine-version-independent conclusion about `ICppStructOps`; it must be narrowed to the verified engine revision.
- historical `Bind_*.cpp` counts are stale whenever either revision advances.
- public Hazelight docs and the current private source branch may describe different revisions.

The implementation must display these as “needs revalidation” rather than silently copying the conclusions.

## Repeatable update procedure

1. Record the previous Hazelight audit marker without changing it.
2. Verify configured local Hazelight/ordinary engine roots are present and distinct; otherwise label the local engine diff unavailable.
3. Fetch current private-repository metadata and run the read-only Hazelight update audit.
4. Pin the observed Hazelight commit and local published plugin commit.
5. Classify commits by comparison family.
6. Inspect both source sides and tests for every changed row.
7. Update the comparison row, evidence keys, date, confidence, and relationship.
8. Create a separate OpenSpec only if a local behavior change is proposed.
9. Run source-key, revision-staleness, and Wiki browser checks.
10. Advance the global Hazelight audit marker only in the workflow that owns that marker.

No ordinary Wiki build/test command may access the private Hazelight repository or the network.
