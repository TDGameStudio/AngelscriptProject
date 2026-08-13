## Context

The plugin has three adjacent but deliberately different mechanisms:

- one-shot snippets under `/Angelscript/Memory/Immediate/`, whose unique module is discarded by default;
- normal disk/generated scripts, whose lifecycle is selected by existing script roots and Hot Reload;
- Cache V2 under `Saved/Angelscript/CacheV2/`, which is a disposable compiler acceleration store rather than user-authored revision history.

Project authors can already build AngelScript editor menus and subsystems, but menu callback objects are temporary and there is no common way to compile a transient class tool, retain one logical session, rerun it, reset it, or recover its source after restarting the Editor. `Reference/ASEditorAutomationBridge` proves class-based reflected dispatch and instance reuse, but its global subsystem, product workflow directory, transport, audit and helper catalogue are not reusable plugin responsibilities.

Most source iteration belongs in Editor, while execution of an already-loaded tool class is also useful in Debug, DebugGame and Development Runtime. Runtime must remain passive: it must not acquire an `UnrealEd` dependency, scan tools, write workspace history, or select a process/world lifetime for the user.

## Goals / Non-Goals

**Goals:**

- Let C++, AngelScript and Blueprint callers explicitly run an already-loaded `UAngelscriptTool` subclass through a caller-owned runner.
- Keep one logical tool session per runner, stable tool-class path and session key without describing that reuse as a process singleton.
- Return a stable session identifier so a renamed or removed class's old session can still be reset exactly.
- Propagate the invocation's explicit ContextObject through the current AngelScript engine/world scope during dispatch.
- Let Editor callers compile without running, run the currently active compiled source without recompiling, or use a compile-and-run convenience operation.
- Preserve logical-session state across the existing code-only and compatible Editor structural reload boundaries while distinguishing physical UObject replacement.
- Expose the currently active last-known-good class/revision after an attempted source update fails.
- Keep bounded local source revisions, compile attempts and optional run summaries for explicitly submitted Editor memory tools so users can recover and iterate on temporary tools.
- Keep source recovery inert: loading history never compiles, executes or restores a prior UObject session.

**Non-Goals:**

- Tool discovery from project/plugin script roots, a `Script/Tools` rule, product tool registry, categories, favourites, built-in tools or automatic instantiation.
- An official editor window, menu, console command, Content Browser asset, commandlet or transport endpoint.
- Asynchronous jobs, Tick, progress, cancellation, polling, deterministic reset callbacks or external-resource lifecycle management.
- Saving/restoring tool UObject fields across Editor restarts, serializing UObject references, or replaying prior invocations.
- Arguments/Payload JSON persistence in v1, global AngelScript compile history, Cache V2 browsing or treating Cache V2 as a recovery source.
- Dynamic source compilation outside Editor, source-module unloading or Development structural reinstancing.
- A sandbox, automatic transactions, undo/rollback or remote authorization around trusted tool code.

## Decisions

### 1. A runner-scoped multiton owns logical sessions

`UAngelscriptToolLibrary::CreateRunner(UObject* Owner)` creates an `RF_Transient` `UAngelscriptToolRunner` with the supplied non-null owner. The caller must retain the runner through a reflected strong reference. No global subsystem, singleton, registry or tick owner retains it.

The runner contains a `UPROPERTY(Transient)` map from `FAngelscriptToolSessionId` to `TObjectPtr<UAngelscriptTool>`. The reflected session identifier contains the exact stable tool-class path string and normalized `FName` session key; `NAME_None` normalizes to `Default`. `RunTool` returns this identifier and `ResetSession` accepts it, so the old session remains exactly addressable after its class is renamed or removed.

The first call for a runner/session creates a transient tool object with the runner as Outer. Repeated calls reuse that logical session. Different runner, class path or key means a different object. `ResetSession` removes one entry and `ResetAllSessions` clears only that runner. Releasing all reflected references makes the runner and its tools eligible for normal GC; reset is not synchronous destruction and v1 exposes no script cleanup callback.

This is a runner-scoped multiton, not a singleton: a project may create any number of runners and may choose an Editor subsystem, GameInstance subsystem, actor, service or short-lived command object as owner.

An `UEngineSubsystem` owner was rejected because it would introduce implicit process-wide state. A temporary runner created inside each call was rejected because it cannot preserve a session. A class-pointer-only reset API was rejected because a removed class makes an orphaned session hard to address.

### 2. One synchronous reflected event is the Runtime contract

`UAngelscriptTool` is `Abstract`, `BlueprintType` and `Blueprintable` and declares a `BlueprintNativeEvent`:

```cpp
FAngelscriptToolResponse Run(const FAngelscriptToolInvocation& Invocation);
```

`FAngelscriptToolInvocation` contains `SessionKey`, `ContextObject` and `ArgumentsJson`. `ArgumentsJson` is empty or a JSON object and is capped at 1 MiB of UTF-8. `FAngelscriptToolResponse` contains `bSuccess`, `Message` and an empty-or-object `PayloadJson`; the payload is also capped at 1 MiB. The cap applies before parsing or returning data so a local tool cannot accidentally force unbounded framework allocation.

`FAngelscriptToolRunResult` contains `EAngelscriptToolRunStatus`, stable `SessionId`, message and payload. Status values are `Succeeded`, `ToolFailed`, `DisabledByBuild`, `InvalidRequest`, `InvalidResponse`, `Busy` and `ExecutionException`.

Normal `ProcessEvent` dispatch does not return the underlying AngelScript execution status. The implementation therefore adds a narrow thread-local reflected-call exception capture in the existing generated-function dispatch path. It reports only when the actual VM context or StaticJIT execution for a reflected call ends with an exception; the Runner scopes the capture around the tool event and converts the captured failure to `ExecutionException`. It does not scrape logs, suppress existing exception reporting or retain an exception after the synchronous call.

Calls are synchronous and Game Thread-only. A private per-runner active-session set rejects recursion into the same session as `Busy`; nesting a different already-loaded session is allowed. A narrow process dispatch-depth counter is incremented only around Runtime tool dispatch so every Editor compile operation can reject `Busy` while any tool is on the Game Thread call stack. This counter retains no runner, class or tool and exists only because Full Reload is unsafe inside any reflected dispatch stack.

A boolean-only result was rejected because callers would need log scraping. Streaming handles and lifecycle callbacks were rejected because they would pull cancellation, cleanup and long-job policy into a synchronous v1. Tools that register delegates, start latent work or own external resources must use an existing user-owned subsystem/service rather than assume Runner reset is deterministic cleanup.

### 3. ContextObject controls the scoped AngelScript WorldContext

Before reflected dispatch, `RunTool` resolves the current `FAngelscriptEngine` and enters `FAngelscriptEngineScope(CurrentEngine, Invocation.ContextObject)`. A non-null valid ContextObject therefore establishes the outer AngelScript WorldContext for the call.

Existing generated instance-method dispatch temporarily changes the ambient WorldContext to the receiver UObject. To preserve the explicit invocation context through that behavior, the Runner also sets a private non-reflected weak `ActiveContextObject` on the tool for only the duration of `Run`, restoring the previous value afterward. `UAngelscriptTool::GetWorld()` resolves that active object through `GEngine->GetWorldFromContextObject(..., ReturnNull)`, returning null when GEngine is absent or the active context is the tool itself. World-sensitive bindings that observe the tool as their ambient context therefore reach the invocation's World through the tool's `GetWorld()` instead of recursing back through the ambient object.

A null ContextObject does not derive a World from the runner Owner, `GEditor`, PIE or GameInstance. The outer engine scope remains well formed, but `UAngelscriptTool::GetWorld()` returns null during that dispatch; tools requiring a World must validate their invocation or allow the downstream binding to report an invalid World Context. Both the active tool context and previous engine/WorldContext are restored even after script failure.

ContextObject does not participate in session identity. The same logical session may run against different worlds on different calls. The invocation reference is not retained automatically; a tool that deliberately saves it in a `UPROPERTY` assumes normal UObject lifetime responsibility.

Passing ContextObject only as data was rejected because many existing bindings resolve World through the engine scope rather than the event parameter.

### 4. Editor source compilation and execution are separable

The stateless `UAngelscriptEditorToolLibrary` exposes three operations:

1. `CompileToolSource`: validate and compile full source, resolve the exact generated tool class, record history according to policy, and return without creating or running a session.
2. `RunCompiledTool`: resolve an already-active memory tool by exact SourceId/module and ToolClassName, call the supplied Runtime runner, and optionally record a run summary without recompiling.
3. `CompileAndRunSource`: convenience composition of compile followed by run only when the attempted compile succeeds.

This separation supports compile-only diagnostics, compile once/run many, multiple SessionKeys, and running the active last-known-good version after a failed attempted update. Runtime callers with a normal already-loaded class continue to call `UAngelscriptToolRunner::RunTool` directly and never enter Editor history code.

The compile request contains SourceId, full SourceText, exact ToolClassName and HistoryPolicy, defaulting to `SourceAndDiagnostics`. The run-compiled request contains Runner, SourceId, exact ToolClassName, Invocation and HistoryPolicy, defaulting to `None` because it has no source/diagnostics to record; callers explicitly select `SourceDiagnosticsAndRunSummary` when they want a run summary. The convenience request composes both shapes and defaults to `SourceAndDiagnostics`.

A compile-and-run-only surface was rejected because it couples source iteration to a mutation and cannot express recovery or repeated runs. A stateful Editor source manager was rejected because active module identity already exists in the AngelScript engine and history is a disk record rather than an execution owner.

### 5. SourceId defines one stable memory module with bounded input

SourceId is an extensionless slash-separated identifier. Each segment is 1-64 ASCII letters, digits, `_` or `-`; the canonical complete identifier is at most 160 characters. Dot segments, empty segments, backslashes, leading/trailing slashes and extensions are rejected before preprocessing or history access.

For example:

```text
MyPlugin/FixMaterials
  -> /Angelscript/Memory/Tools/MyPlugin/FixMaterials.as
  -> Angelscript.Memory.Tools.MyPlugin.FixMaterials
```

ToolClassName is one unqualified Unreal object/class identifier: 1-128 ASCII characters, beginning with a letter or `_` and followed only by letters, digits or `_`. SourceText must be non-empty after trimming and is capped at 1 MiB of UTF-8. Both are rejected before preprocessing or history access when invalid. The Editor constructs `FAngelscriptSource`, preprocesses it through `AddSource`, and compiles through the existing `ECompileType::FullReload` path because the source may introduce or structurally change a generated UObject class. The class generator can still reduce body-only work internally.

Compile results return at most 512 scoped diagnostics. Each diagnostic message is capped at 64 KiB of UTF-8 and the result exposes `bDiagnosticsTruncated`; Tool History stores exactly that bounded diagnostic view. These limits keep malformed temporary source from creating an unbounded reflected result or history record.

Repeating a SourceId updates one stable module identity. Unique SourceIds and their generated classes remain loaded until engine shutdown in v1; session reset and history deletion do not promise module unloading. Callers therefore use a bounded, reusable set such as `Scratch/CurrentTool` rather than timestamp/GUID identifiers.

### 6. Exact module-local class resolution and last-known-good reporting

On success, the Editor library resolves exact ToolClassName only in the module descriptor produced by the attempted compile. The class must be concrete, non-deprecated and derived from `UAngelscriptTool`; no global same-name fallback is allowed.

Before an attempted update, the compile operation snapshots the currently active exact module/class for the same SourceId and ToolClassName. Its result distinguishes:

- AttemptStatus and scoped diagnostics for the submitted source;
- AttemptedRevisionId when history records the source;
- ResolvedToolClass for a successful attempted compile;
- ActiveToolClass and ActiveRevisionId for the version that remains published after the attempt;
- `bHasLastKnownGood` when a previous successfully compiled revision remains active after failure.

On compile failure, the new source is never dispatched and existing runner sessions are not reset. If the engine retains the prior published module, `RunCompiledTool` can resolve and run it. This is observation of the engine's existing failed-reload behavior, not a second module rollback system. If no prior module exists, the result reports no active class.

RunCompiledTool repeats exact module-local validation on every call rather than trusting a stale UClass pointer supplied by history. Loading a historical revision returns source data only; a user must explicitly submit it to CompileToolSource before it can become active.

### 7. Reload preserves logical sessions within existing guarantees

- Repeated calls without reload reuse the exact physical tool UObject.
- Editor body-only reload keeps that object and executes new function code while preserving all of its state.
- Editor structural reload may replace the physical UObject through normal UE reinstancing. The same `FAngelscriptToolSessionId` remains the logical session, the runner's reflected reference is fixed up, and only compatible reflected `UPROPERTY` state is guaranteed to migrate.
- Raw/non-reflected state, delegate registrations, external resources and incompatible properties are not guaranteed to migrate.
- Class rename/removal/incompatible identity does not imply migration. The old entry remains addressable by its returned SessionId until exact reset or runner release.
- Development packaged code-only reload continues with the loaded class/session. Structural reload remains `RequiresRestart`; the tool layer does not initiate or bypass packaged reload.

Calling a structural reinstance “the same object” was rejected because it obscures physical replacement and could encourage unsafe raw pointer retention.

### 8. Editor Tool History is a local revision store, not a catalogue

Only calls that explicitly submit a Tool Source request can write history. `EAngelscriptToolHistoryPolicy` has:

- `None`;
- `SourceAndDiagnostics` (the compile and compile-and-run default);
- `SourceDiagnosticsAndRunSummary`.

The default records the explicitly submitted source and diagnostics because recoverable iteration is the purpose of this Editor source surface. A caller can select None, and Editor per-project user settings can disable all Tool History. Runtime RunTool, ordinary disk-script compilation, Snippet execution and compilation-event broadcasts never write this store.

After request validation succeeds, the Editor adapter best-effort publishes the immutable source revision before preprocessing so a submitted temporary tool can still be recovered if the compiler or Editor terminates during the attempt. Compilation proceeds even when that journal write fails. After compilation and exact class validation, it publishes a separate attempt record and updates last-known-good only for a successful valid tool class. `CompileAndRunSource` returns nested compile and run results so revision/attempt history and optional run-summary history keep independent statuses rather than being collapsed into one ambiguous flag.

History lives at:

```text
Saved/Angelscript/ToolHistory/v1/
  index.json
  Sources/<blake3(canonical-source-id)>/
    manifest.json
    Revisions/<revision-id>.json
    Attempts/<attempt-id>.json
    Runs/<run-id>.json
```

The project-standard BLAKE3 hash is a storage key only; every record contains the canonical SourceId and schema version and is validated against the requested identity. RevisionId is content-addressed with `FAngelscriptArtifactCanonicalWriter` from a v1 domain, canonical SourceId, ToolClassName and exact UTF-8 source, so identical source submissions reuse one immutable revision without concatenation ambiguity. Every compile still writes a separate attempt record referring to that revision, preserving repeated success/failure diagnostics without duplicating source text. Run summaries contain revision/source identity, SessionKey, status, bounded message and timestamps; v1 never persists ContextObject, ArgumentsJson or PayloadJson.

Each immutable record is written as UTF-8 JSON through a same-directory temporary file and atomic replace. Per-source manifest and root index pointers are published after immutable records. List/load validates schema, containment, identifier/hash agreement and size before returning data. A corrupt index is reported and can be rebuilt from valid bounded manifests; corrupt individual records are skipped with diagnostics rather than compiled or executed.

This index exists only to find local revisions when an API caller asks. It does not discover project tools, register runnable classes, hold UObjects or create sessions.

### 9. History is bounded and failures are non-authoritative

`UAngelscriptEditorToolSettings` uses Editor-per-project-user config and defaults to:

- history enabled;
- at most 100 SourceIds;
- at most 50 source revisions, 100 compile attempts and 100 run summaries per SourceId;
- at most 256 MiB for the whole Tool History root;
- the 1 MiB source/arguments/payload API limits defined above.

After successfully publishing a new record, deterministic retention removes oldest unpinned entries first. The newest revision and current last-known-good revision are protected while their SourceId remains indexed. If the configured limit cannot admit a record without deleting protected data, history returns a separate failure/warning and leaves compile/run success unchanged. No history filesystem error changes the authoritative compile or run status.

List APIs accept a Limit from 1 through 200 and return newest-first metadata. Load returns a selected immutable source revision and diagnostics without compiling. `ForgetToolHistory(SourceId)` first moves the exact validated source directory to an ignored same-parent tombstone, atomically publishes index removal, and then deletes the tombstone; failed publication restores the source directory when possible. It does not unload a module, reset a runner or delete a user script. Stale tombstones are inert and eligible for bounded maintenance. There is no broad clear-all reflected API in v1.

Unbounded append-only history was rejected because tools may be iterated frequently. Automatically saving raw invocation data was rejected because it may contain credentials, local paths or large private payloads.

### 10. Restricted builds fail closed without removing reflected Runtime types

Runtime reflected tool/session/invocation/result types compile in all configurations. `RunTool` rejects Test and Shipping with `DisabledByBuild` before instance creation or dispatch. Debug, DebugGame, Development and Editor may execute an already-loaded class according to normal AngelScript availability.

All memory-source compile, run-compiled and Tool History types live in `AngelscriptEditor`. Non-Editor targets expose no source compilation or history entry point. This build gate controls this runner only and is not a security sandbox around arbitrary project AngelScript calls.

## Risks / Trade-offs

- [Unbounded SourceIds retain modules] -> Validate bounded stable SourceIds, document reusable scratch identities and defer module unloading until class retirement is proven safe.
- [Full Reload affects objects beyond the tool] -> Use the existing class-generator/reinstancing path, reject compile during active runner dispatch and document normal Editor reload impact.
- [Physical object replacement is mistaken for pointer stability] -> Specify logical-session continuity separately and guarantee migration only for compatible reflected properties.
- [Failed compile appears to erase a usable tool] -> Return ActiveToolClass/last-known-good metadata and allow explicit RunCompiledTool without recompilation.
- [ContextObject is present but ambient World is wrong] -> Enter and test `FAngelscriptEngineScope` around reflected dispatch and restore it on every result path.
- [History writes secrets or grows indefinitely] -> Persist no invocation arguments/payload/context in v1, provide policy/settings controls, enforce byte/count limits and deterministic retention.
- [History corruption prevents recovery] -> Use immutable atomically published records, validate every read, make index rebuildable and never auto-execute recovered data.
- [History failure masks successful work] -> Return an independent history status/warning; compile/run status remains authoritative.
- [Renamed classes leave unreachable session objects] -> Return string-based SessionId and reset by exact identifier rather than requiring a live UClass.
- [Runner reset is mistaken for deterministic cleanup] -> Document GC semantics and exclude long-lived jobs/resources from the synchronous v1 contract.
- [Trusted tools mutate editor/runtime state] -> State the trust boundary and add no automatic transaction, remote transport or rollback claim.

## Migration Plan

1. Add failing Runtime tests, then implement the reflected tool/session contract, stable SessionId, WorldContext scope and synchronous runner without changing Snippet behavior.
2. Add compile-only and run-compiled Editor tests, then implement stable memory-source compilation, exact class resolution and last-known-good reporting.
3. Add body-only, structural, failed-reload, rename and exact-reset tests using inline AS fixtures.
4. Add a bounded Editor Tool History store with fail-closed reads, atomic publication, retention and explicit recovery APIs; keep all persistence results separate from compile/run status.
5. Document caller ownership and examples in the Chinese Editor extension guide first, then the plugin README.
6. Verify Runtime/Editor prefixes, Snippet regressions, Editor build and Development/Shipping package compilation.

Rollback removes the new Tooling files, tests and documentation. No persistent asset, global registry or setting migration is required. Saved Tool History is disposable local user data; older/unsupported schema is ignored with a diagnostic, never automatically upgraded and never loaded as executable code.

## Open Questions

None for v1. Asynchronous jobs, deterministic cleanup callbacks, source-module unloading, cross-restart tool-state serialization, invocation replay, external transports and higher-level tool catalogues require separate changes with their own ownership and security contracts.
