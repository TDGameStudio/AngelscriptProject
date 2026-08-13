## Why

`FAngelscriptSnippetRunner` intentionally executes isolated one-shot source and discards its module by default, so it cannot provide a stable UObject instance or an iterative workspace for editor and Development tools. The plugin already has memory source descriptors, canonical virtual paths, class generation, Hot Reload and editor reinstancing; it now needs a narrow execution and Editor-local revision contract that users can compose without the plugin owning their tool catalogue or workflow product.

## What Changes

- Add a caller-owned `UAngelscriptToolRunner` and an abstract `UAngelscriptTool` contract for synchronous, stateful execution of an explicitly supplied, already-loaded tool class.
- Reuse one transient tool UObject per runner and stable session identity; return a resettable `FAngelscriptToolSessionId` and make clear that this is runner-scoped reuse rather than a process singleton.
- Return deterministic reflected invocation/result types for C++, AngelScript and Blueprint callers, including JSON-object arguments/payloads and framework failure states.
- Propagate an invocation's explicit ContextObject through the current AngelScript engine/world scope while dispatching the tool.
- Add Editor-only compile-only, run-compiled and compile-and-run entry points for explicitly supplied full source under a stable `/Angelscript/Memory/Tools/<SourceId>.as` identity; compilation can succeed without executing the tool.
- Preserve compatible logical-session state across existing code-only Hot Reload and editor class reinstancing boundaries, distinguish physical UObject replacement, and return the currently active last-known-good class after a failed update when available.
- Add policy-controlled, bounded Editor-local source revision, compile-attempt and run-summary history under `Saved/Angelscript/ToolHistory/v1/`, with list/load/exact-forget APIs and no automatic compilation or execution during recovery.
- Keep `FAngelscriptSnippetRunner` unchanged and keep Test/Shipping execution disabled while retaining reflected API types for build compatibility.
- Do not add a project tool directory convention, project-script scan, product tool registry, built-in tool scripts, window, menu, console command, asynchronous scheduler, remote transport, MCP integration, cross-restart UObject-state restoration or broad editor automation library.

## Capabilities

### New Capabilities

- `as-stateful-tool-execution`: Caller-owned stateful AngelScript tool objects, explicit synchronous execution/reset contracts, Editor memory-source execution, Hot Reload state rules and build availability.
- `as-tool-workspace-history`: Policy-controlled bounded Editor-local history for explicitly submitted memory tool sources, compile attempts and run summaries, including safe recovery APIs and retention behavior.

### Modified Capabilities

- `as-virtual-script-paths`: Reserve a stable Editor tool-source convention under `/Angelscript/Memory/Tools/` while preserving the isolated `/Angelscript/Memory/Immediate/` snippet identity.

## Impact

- Future implementation affects `Plugins/Angelscript/Source/AngelscriptRuntime/Tooling`, one narrow Runtime reflected-dispatch exception observation seam, `Plugins/Angelscript/Source/AngelscriptEditor/Tooling` and their Runtime/Editor automation tests.
- Adds reflected public Runtime and Editor types callable from C++, AngelScript and Blueprint; no new Runtime module dependency, global subsystem, tick owner or persistent asset is required.
- Uses the existing preprocessor, source descriptor, class generator, compilation diagnostic and Hot Reload pipelines rather than introducing a parallel compiler path.
- Writes only explicitly requested Editor-local history beneath `Saved/Angelscript/ToolHistory/v1/`; it does not reinterpret Cache V2 as user history and does not write execution history from Runtime `RunTool`.
- Normal project scripts remain user-owned and may live anywhere already covered by the existing script roots; this change adds no checked-in product tool scripts and no packaging-root change.
- Existing Debug MCP and observability Toolset changes remain independent external consumers and are neither dependencies nor implementation targets of this change.
