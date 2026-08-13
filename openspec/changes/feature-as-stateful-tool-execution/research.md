# Stateful AngelScript Tool Execution Research

## Question

Determine the smallest reusable execution and recovery surface that lets project authors iterate on AngelScript editor/development tools with stable caller-owned state, without turning `AngelscriptRuntime` into a tool catalogue or copying the product-specific automation stack from `Reference/ASEditorAutomationBridge`.

## Current plugin evidence

### Snippet execution is deliberately one-shot

- `AngelscriptRuntime/Core/AngelscriptSnippet.*` creates a unique `/Angelscript/Memory/Immediate/Snippet_<id>.as` source and matching module for every invocation.
- Statement mode wraps source in a generated global function; full-source mode invokes `void Main()`.
- Modules are discarded by default. Keeping a module is a debugging option, and repeated labels intentionally remain isolated rather than identifying a session.

Conclusion: adding class instances, stable identities and a session map to `FAngelscriptSnippetRunner` would mix two incompatible lifetime contracts. Snippets remain isolated and the stateful tool API is separate.

### Stable memory identity already exists

- `FAngelscriptSource::FromMemorySource` and `FAngelscriptPreprocessor::AddSource` already compile source without a physical filename.
- `FAngelscriptVirtualPath` accepts `/Angelscript/Memory/<Provider>/...`; memory module names are deterministically derived from the virtual path.
- `/Angelscript/Memory/Tools/<SourceId>.as` therefore needs a reserved convention and tests, not a second virtual filesystem or source provider.

### Existing reload behavior can carry state

- Body-only `SoftReloadOnly` updates keep the generated class and existing object instance usable with new code.
- Editor `FullReload` is connected to `ClassReloadHelper` and UE reinstancing. References stored through reflected `UPROPERTY` containers can be fixed up, and compatible reflected properties can migrate.
- Packaged Development reload rejects structural changes and reports `RequiresRestart`; it does not simulate Editor reinstancing.
- A failed reload keeps the previous active class/module available.

Conclusion: a caller-owned UObject containing a `UPROPERTY(Transient)` instance map is sufficient. The tool layer must state the existing state guarantees rather than invent another migration system.

The important distinction is logical versus physical identity. A body-only update can keep the exact UObject, while a compatible structural update may replace it through UE reinstancing and fix up the runner's reflected reference. The session key must therefore be stable data rather than only a live UClass pointer.

### Users already have suitable owners and triggers

- `UScriptEditorSubsystem` provides Editor lifecycle/tick callbacks for user-authored AS code.
- AS editor/actor/asset menu extensions provide user-owned trigger surfaces.
- Runtime callers can own a runner from a GameInstance subsystem, World subsystem, Actor, service object or native plugin.

Conclusion: the plugin must not auto-create a global runner. The user selects the owner and therefore the lifetime and world boundary.

### ContextObject requires an engine scope, not only an event field

- Existing world-sensitive bindings such as Actor spawn resolve `FAngelscriptEngine::TryGetCurrentWorldContextObject()`.
- `FAngelscriptEngineScope(Engine, WorldContext)` already pushes the engine and restores the previous ambient WorldContext on scope exit.
- Generated instance-method dispatch in `ASFunction_CallHelpers.h` temporarily assigns its receiver UObject as WorldContext. A plain UObject tool therefore needs a call-scoped ContextObject bridge in `GetWorld()`; resolving the ambient tool object from `GetWorld()` would recurse.
- Passing ContextObject only inside the invocation would let the tool inspect it but would not make existing world-sensitive bindings use it.

Conclusion: the runner must scope reflected dispatch with the explicit ContextObject, temporarily expose it through the tool's `GetWorld()`, restore both scopes, and never derive an implicit World from its Owner or `GEditor`.

### Reflected dispatch needs a narrow exception observation seam

- `ProcessEvent` returns no AngelScript execution status to its caller.
- The generic VM path in `ASFunction_CallHelpers.h` can observe its own context's `asEXECUTION_EXCEPTION` result, while its StaticJIT path has `FScriptExecution::bExceptionThrown`.
- Parsing `LogAngelscriptException` output would conflate unrelated nested failures and make structured results depend on logging configuration.

Conclusion: a stackable thread-local capture must be notified by the actual reflected VM/StaticJIT completion path and scoped only around the tool event. It observes exceptions without suppressing or replacing existing logs.

### Existing Saved data is not user tool history

- Cache V2 defaults to `Saved/Angelscript/CacheV2/` and understands memory source identities, but it is a disposable compiler acceleration store with compatibility/retention rules rather than a user revision API.
- `FAngelscriptCompilationEvents` exposes process-local compile IDs, phases, module/file summaries and messages, but it has no persistence or recovery contract.
- The current Snippet window keeps its text only in the live Slate widget; it has no recent-source or Saved history.
- Existing state dump, coverage and reference workflow outputs demonstrate bounded paths and atomic/JSON output patterns, not a reusable source-history service.

Conclusion: recovering temporary tools requires a separate Editor-only, schema-versioned revision store. It must record only explicit Tool Source requests and must never reconstruct source from Cache V2.

## `ASEditorAutomationBridge` comparison

The reference validates the feasibility of compiling a full AS source, locating a generated workflow class, creating a transient UObject, reusing it and invoking an exact `Run` function. Its compile diagnostics and module/class validation are useful evidence.

The following reference responsibilities are intentionally rejected for this change:

- named-pipe RPC, action leases and remote client ownership;
- workflow directory constraints, discovery and task naming conventions;
- Begin/Poll/Cancel, progress sinks, product-wide JSONL output and interaction audit policy;
- built-in Blueprint/Widget/Material/Level/Content Browser/PIE helper libraries;
- a global subsystem-owned workflow cache;
- product-specific gameplay-flow and interaction policies.

The retained execution idea is: explicit full source -> exact generated subclass -> caller-owned reusable logical session -> synchronous structured result. The reference's same-directory temporary publication and durable JSON techniques are also implementation evidence for local Tool History, without adopting its transport audit semantics.

## Alternatives

### Extend `FAngelscriptSnippetRunner`

Rejected because unique Immediate modules and default discard are valuable guarantees. Stable class/module/session state would make the existing flags ambiguous and risk regressions in the snippet console and Editor window.

### Editor-only workflow subsystem

Rejected because most first uses are in Editor, but the same already-loaded tool object contract is useful in Development Runtime. An Editor-owned cache would also choose state lifetime on the user's behalf.

### Plugin-managed tool registry and fixed tool pack

Rejected because the tools belong to the project author. A registry, folder scan or built-in tool scripts would create governance and packaging responsibilities unrelated to execution.

### Caller-owned generic runner plus Editor source adapter

Selected. Runtime owns only reflected contracts, scoped WorldContext and instance reuse for explicitly supplied classes. Editor owns dynamic source compilation and policy-controlled local revision history. No execution state is created until a caller creates and retains a runner; no history is written except for an explicit Tool Source request.

### Compile-and-run as the only Editor entry

Rejected because source iteration needs compile-only diagnostics, compile once/run many and an explicit way to run a last-known-good version after an attempted update fails. The Editor surface separates compile-only and run-compiled operations and retains compile-and-run as convenience.

### Use Cache V2 as recoverable source history

Rejected because compiler artifacts are disposable, compatibility-keyed and not a user-readable revision contract. Tool History stores exact source and scoped diagnostics independently; deleting either store does not corrupt the other.

### Persist every AngelScript compile automatically

Rejected because it would turn the plugin into a global source-history manager and capture ordinary project/plugin scripts without an explicit user request. Only the stable Tool Source API can record history.

### Persist tool UObject state and invocation payloads

Rejected for v1. UObject state requires schema/version/reference migration across Editor restarts, while arguments and payloads may contain credentials, local paths or large private data. Recovery restores source, diagnostics and bounded run summaries only.

## Neighboring OpenSpec boundaries

- `improve-as-script-subsystems` may improve user subsystem lifecycle, but this change does not modify those bases or depend on its completion.
- `feature-as-mcp-observability-toolset` exposes read-only Runtime state through UE ToolsetRegistry; it does not execute user AS source.
- `feature-as-debug-mcp-bridge` controls DebugServer sessions out of process; it is not an execution host for editor tools.
- A later adapter may invoke this runner, but no MCP, pipe, console or transport dependency belongs in the initial capability.

## Selected constraints

- Synchronous Game Thread execution only.
- The caller strongly retains the runner; the runner strongly retains transient tool instances.
- Empty or JSON-object arguments and payloads only, each capped at 1 MiB; arbitrary binary or reflected parameter marshalling is deferred.
- Editor compilation, execution and recovery are separate explicit operations; loading history never compiles or executes.
- Editor memory source uses a finite, stable caller-selected SourceId. Source unloading is deferred.
- Explicit Editor Tool Source requests default to bounded SourceAndDiagnostics history under `Saved/Angelscript/ToolHistory/v1/`; callers/settings can disable it, and Runtime never writes it.
- History restores source/diagnostics/run metadata, not Runner sessions or tool UObject state.
- Test and Shipping builds retain the reflected types but reject calls.
- Tool scripts are trusted project/local code. No sandbox or permission boundary is claimed.
