# Stateful AngelScript Tool Execution and Workspace History Implementation Plan

> Plan-only OpenSpec record. Do not implement this change as part of the proposal/review session. Future implementation must preserve user ownership: the plugin supplies execution, iteration and recovery primitives, but no tool catalogue, fixed tool set, discovery scan or product UI.

## Outcome

Implement one caller-owned Runtime runner for already-loaded `UAngelscriptTool` classes, plus an Editor-only memory-source adapter and bounded `Saved` revision store for temporary tool iteration. A runner retains logical sessions only for its own lifetime. Tool History retains source and diagnostics across Editor restarts, but never serializes or restores a tool UObject session.

The implementation is split into four independently testable closures:

1. Runtime session execution, explicit WorldContext propagation and structured failure.
2. Editor compile-only, run-compiled and compile-and-run operations on stable memory modules.
3. Existing Hot Reload/reinstancing behavior expressed as logical-session guarantees.
4. Editor-local source journal, history recovery, retention and exact forget.

## Non-Negotiable Constraints

- Work in the current checkout. Do not create a worktree unless the user later asks for one.
- `Plugins/Angelscript` is a git submodule. Source/tests/README changes are committed in that submodule first; the parent then records its gitlink plus OpenSpec/Chinese guide changes.
- Use TDD and the conventions in `.agents/skills/_angelscript-test-guide/SKILL.md`. Keep all AS fixtures inline or test-owned; do not add a product `.as` tool.
- `AngelscriptRuntime` must not gain `UnrealEd`, `AngelscriptEditor` or Settings dependencies.
- `AngelscriptRuntime` performs no history I/O. `AngelscriptEditor` owns memory-source compilation and every `Saved` operation.
- Test and Shipping retain reflected Runtime types but reject `RunTool` before instance creation.
- No registry, global runner, scan, menu, window, command, transport, tick, latent job, module unload or cross-restart UObject state is part of this change.
- Existing Immediate Snippet identity, default discard and console behavior must remain unchanged.
- At proposal review time, the plugin submodule already contains unrelated in-progress Cache/StaticJIT/ClassGenerator edits, including `ASFunction_CallHelpers.h`. Before implementation, inspect and preserve that live diff; add the exception notification to the then-current dispatch code and stop for user coordination if the overlap cannot be merged without changing the other work's intent.

## File Map

| Repository | Path | Change |
|---|---|---|
| Plugin submodule | `Source/AngelscriptRuntime/Tooling/AngelscriptToolRunner.h` | Add reflected Runtime request/response/status/session types, tool base, runner and factory. |
| Plugin submodule | `Source/AngelscriptRuntime/Tooling/AngelscriptToolRunner.cpp` | Add validation, runner-scoped session storage, context bridge, dispatch guard, exception result mapping and reset. |
| Plugin submodule | `Source/AngelscriptRuntime/Core/AngelscriptReflectedCallExceptionCapture.h` | Add non-reflected thread-local scoped capture API used only around reflected calls. |
| Plugin submodule | `Source/AngelscriptRuntime/Core/AngelscriptReflectedCallExceptionCapture.cpp` | Own capture stack and first-exception result without changing logging. |
| Plugin submodule | `Source/AngelscriptRuntime/ClassGenerator/ASFunction_CallHelpers.h` | Notify the active capture when the actual generic VM/StaticJIT reflected execution ends exceptionally. Extend a specialized dispatch file only if the red test proves the fixed tool signature selects it. |
| Plugin submodule | `Source/AngelscriptTest/Tooling/AngelscriptToolRunnerTestTypes.h` | Add UHT-visible native tool fixtures and deterministic recursion/context/GC controls. |
| Plugin submodule | `Source/AngelscriptTest/Tooling/AngelscriptToolRunnerTestTypes.cpp` | Implement native fixtures with no production registration. |
| Plugin submodule | `Source/AngelscriptTest/Tooling/AngelscriptToolRunnerTests.cpp` | Add `Angelscript.TestModule.Tooling.StatefulToolRunner` tests, including inline AS fixtures. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolSource.h` | Add reflected compile/run/composed requests and results plus the stateless Editor library. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolSource.cpp` | Add validation, stable virtual identity, Full Reload, diagnostics, exact class resolution, last-known-good observation and runner dispatch. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryTypes.h` | Add history policy/status/metadata/results and Editor-per-project-user settings. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryStore.h` | Declare unreflected validated store primitives and test dependency seams. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryStore.cpp` | Implement BLAKE3 identities, JSON records, atomic publication, retention, rebuild and tombstone deletion. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryLibrary.h` | Add reflected bounded data-only list/load/rebuild/forget APIs. |
| Plugin submodule | `Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryLibrary.cpp` | Validate public requests and delegate to the store without compiling or executing. |
| Plugin submodule | `Source/AngelscriptEditor/Tests/AngelscriptEditorToolSourceTests.cpp` | Add `Angelscript.Editor.ToolExecution` compile/run/reload tests. |
| Plugin submodule | `Source/AngelscriptEditor/Tests/AngelscriptEditorToolHistoryTests.cpp` | Add `Angelscript.Editor.ToolHistory` pure store, policy, recovery, retention and corruption tests. |
| Parent repository | `Documents/Knowledges/ZH/Guide_EditorExtension.md` | Document Chinese-first usage, ownership, lifecycle, recovery and trust boundaries. |
| Plugin submodule | `README.md` | Add concise English consumer documentation after the Chinese guide. |

No Build.cs change is expected: Runtime already depends on JSON support, and Editor already has Runtime, JSON, Settings and DeveloperSettings support. Add a dependency only if a compile error proves the current module graph insufficient, and record that evidence in the OpenSpec verification log.

## Public Contract to Implement

### Runtime reflected types

Use these names and semantics; minor UHT-required declaration syntax may change, but not the represented contract.

`EAngelscriptToolRunStatus`:

- `Succeeded`
- `ToolFailed`
- `DisabledByBuild`
- `InvalidRequest`
- `InvalidResponse`
- `Busy`
- `ExecutionException`

`FAngelscriptToolSessionId`:

- `FString ToolClassPath`: exact `UClass::GetPathName()` captured when the session is admitted.
- `FName SessionKey`: normalized key; `NAME_None` becomes `Default`.
- Native `operator==`, `GetTypeHash` and `IsValid` so it is a stable private `TMap` key and reflected reset token.

`FAngelscriptToolInvocation`:

- `FName SessionKey`
- `TObjectPtr<UObject> ContextObject`
- `FString ArgumentsJson`

`FAngelscriptToolResponse`:

- `bool bSuccess`
- `FString Message`
- `FString PayloadJson`

`FAngelscriptToolRunResult`:

- `EAngelscriptToolRunStatus Status`, defaulting to `InvalidRequest`
- `FAngelscriptToolSessionId SessionId` when identity was successfully resolved
- `FString Message`
- `FString PayloadJson`

`UAngelscriptTool`:

- Abstract, BlueprintType, Blueprintable and Transient.
- `BlueprintNativeEvent FAngelscriptToolResponse Run(const FAngelscriptToolInvocation& Invocation)`.
- Base implementation returns a deterministic unsuccessful response.
- `GetWorld()` resolves only the private call-scoped ContextObject; it returns null when GEngine is absent or that context is the tool itself, and has no Owner, GEditor, PIE or GameInstance fallback.
- The call-scoped context is non-reflected, weak, restored after dispatch and never becomes persisted tool state.

`UAngelscriptToolRunner`:

- BlueprintType and Transient.
- `RunTool(TSubclassOf<UAngelscriptTool>, const FAngelscriptToolInvocation&)`.
- `ResetSession(const FAngelscriptToolSessionId&)`.
- `ResetAllSessions()`.
- Private `UPROPERTY(Transient) TMap<FAngelscriptToolSessionId, TObjectPtr<UAngelscriptTool>>`.
- Private non-reflected active-session set.
- A non-reflected exported `IsAnyToolDispatchActive()` seam for the Editor Full Reload guard; it exposes no runner/session enumeration.

`UAngelscriptToolLibrary::CreateRunner(UObject* Owner)`:

- Reject null, invalid or unreachable owners with null.
- Construct one `RF_Transient` runner using Owner as Outer.
- Do not use `DefaultToSelf`, a subsystem fallback or a global strong reference.

### Runtime fixed limits and validation order

1. Reject Test/Shipping, off-thread calls, invalid class and invalid arguments before constructing an instance.
2. Tool class must be non-null, concrete, non-deprecated and derived from `UAngelscriptTool`.
3. Empty `ArgumentsJson` is allowed. Non-empty input must be a JSON object and at most 1 MiB after UTF-8 conversion.
4. Build the session identity from exact class path and normalized key.
5. Existing sessions may run at capacity; a new identity is rejected as `InvalidRequest` when the runner already owns 256 sessions.
6. Reject same-session recursion as `Busy`. A different session may nest.
7. Enter `FAngelscriptEngineScope(CurrentEngine, ContextObject)`, set the tool's call-scoped context, start reflected-call exception capture and increment process dispatch depth only around `Run`.
8. Restore depth, active key, call-scoped context and engine scope on every return path with RAII.
9. Captured AS exception wins over the response and maps to `ExecutionException`.
10. Otherwise validate Message at 64 KiB UTF-8 and empty-or-object PayloadJson at 1 MiB UTF-8. Invalid output maps to `InvalidResponse`.
11. A valid response maps `bSuccess` to `Succeeded` or `ToolFailed` without log scraping.

The process dispatch-depth value may be thread-safe storage, but it retains no UObject and is not an execution singleton. Its sole consumer is the Editor compile guard.

### Reflected exception capture

Implement `FAngelscriptScopedReflectedCallExceptionCapture` as a stackable thread-local scope:

- The active scope captures the first exception message and exposes `HasException()` and a bounded message getter.
- The generic reflected VM path reports only after its own context finishes in `asEXECUTION_EXCEPTION`.
- The generic StaticJIT path reports only when its own `FScriptExecution::bExceptionThrown` is true.
- Existing log/debug-server behavior remains untouched.
- A nested scope receives its own exception; after it pops, the outer scope is restored.
- Do not install a global log listener and do not classify arbitrary Error logs as execution exceptions.

### Editor source types

`EAngelscriptEditorToolStatus`:

- `Succeeded`
- `InvalidRequest`
- `Busy`
- `CompileFailed`
- `ToolClassNotFound`
- `InvalidToolClass`
- `ActiveToolNotFound`
- `RunFailed`

`FAngelscriptToolCompileDiagnostic`:

- Virtual path, severity, message, one-based row and column.

`FAngelscriptEditorToolCompileRequest`:

- `FString SourceId`
- `FString SourceText`
- `FString ToolClassName`
- `EAngelscriptToolHistoryPolicy HistoryPolicy = SourceAndDiagnostics`

`FAngelscriptEditorToolCompileResult`:

- Status, message, virtual path and module name.
- `AttemptedRevisionId`, empty only when policy/settings/history failure leaves it unavailable.
- `ResolvedToolClass` for a successful attempted source.
- `ActiveToolClass` and optional `ActiveRevisionId` for the exact version left published.
- `bHasLastKnownGood` only when a failed attempted update leaves a prior exact valid class active.
- At most 512 scoped diagnostics plus `bDiagnosticsTruncated`.
- Independent `FAngelscriptToolHistoryResult History`.

`FAngelscriptEditorToolRunRequest`:

- Runner, SourceId, ToolClassName, Invocation and `HistoryPolicy = None`.

`FAngelscriptEditorToolRunResult`:

- Editor status/message, exact resolved active class, optional history-derived active RevisionId, nested Runtime run result and independent run-summary History result.

`FAngelscriptEditorToolCompileAndRunRequest`:

- SourceId, SourceText, ToolClassName, Runner, Invocation and `HistoryPolicy = SourceAndDiagnostics`.

`FAngelscriptEditorToolCompileAndRunResult`:

- Overall composed status.
- Nested compile result.
- Nested run result, populated only after compile success.

`UAngelscriptEditorToolLibrary` exposes `CompileToolSource`, `RunCompiledTool` and `CompileAndRunSource`. It owns no persistent UObject, source manager or session map.

### Source validation and identity

- SourceId is canonical, extensionless and slash-separated.
- Complete SourceId length: 1-160 ASCII characters.
- Segment length: 1-64; allowed characters are letters, digits, `_` and `-`.
- Reject dot segments, empty segments, leading/trailing slash, backslash, extension and non-ASCII input.
- ToolClassName is one unqualified identifier of 1-128 ASCII characters: first character letter or `_`, remainder letters/digits/`_`.
- SourceText must be non-empty after trimming and no more than 1 MiB UTF-8.
- Derive source with `FAngelscriptVirtualPath::FromMemoryRelativePath(TEXT("Tools"), SourceId + TEXT(".as"))`.
- Expected virtual path: `/Angelscript/Memory/Tools/<SourceId>.as`.
- Expected module: `Angelscript.Memory.Tools.<SourceId with slash replaced by dot>`.
- Perform all validation before diagnostics mutation, preprocessing, history access or filesystem resolution.

### Compile/run behavior

`CompileToolSource`:

1. Require Game Thread and reject `Busy` when any Runtime tool dispatch is active.
2. Snapshot the current expected module's exact valid class and any validated history last-known-good association.
3. Under a recording policy, best-effort journal the immutable source revision before preprocessing.
4. Reset diagnostics only for the expected virtual path and the compiler's transient unscoped bucket.
5. Build `FAngelscriptSource`, add it to `FAngelscriptPreprocessor` and preprocess.
6. Compile the returned modules with `ECompileType::FullReload` inside the current engine scope.
7. Treat only `FullyHandled` or `PartiallyHandled` as compile success, then retrieve the expected active module.
8. Search only that module descriptor's classes for exact ToolClassName. Never use `FindObject` or a global same-name fallback.
9. Validate the class base/abstract/deprecated flags.
10. Collect only matching virtual-path diagnostics, clamp to 512, clamp each message to 64 KiB UTF-8 and mark truncation.
11. Publish an attempt record after preprocessing/compile was reached. Update manifest last-known-good only after valid class resolution succeeds.
12. On failure, re-resolve the pre-existing exact module/class; report it as active only if it still validates. Never dispatch or reset a runner.

`RunCompiledTool`:

1. Validate request and resolve the expected active module without preprocessing.
2. Search and revalidate the exact class on every call.
3. Call the supplied Runtime runner.
4. Map a non-succeeded Runtime status to Editor `RunFailed` while preserving the nested Runtime result.
5. Record a summary only for `SourceDiagnosticsAndRunSummary`; never persist arguments, payload or context.

`CompileAndRunSource`:

1. Call compile-only.
2. Stop on every non-successful compile/class result, including when last-known-good remains available.
3. Construct run-compiled from the same identity and invoke it only for the just-successful active source.
4. Return nested results so compile history failure and run-summary failure are independently visible.

### Tool History reflected contract

`EAngelscriptToolHistoryPolicy`:

- `None`
- `SourceAndDiagnostics`
- `SourceDiagnosticsAndRunSummary`

`EAngelscriptToolHistoryStatus`:

- `NotRequested`
- `Disabled`
- `Succeeded`
- `SucceededWithWarnings`
- `NotFound`
- `InvalidRequest`
- `CapacityExceeded`
- `CorruptData`
- `ReadFailed`
- `WriteFailed`
- `DeleteFailed`

`FAngelscriptToolHistoryResult` contains status, bounded message/warnings and booleans indicating whether revision, attempt or run records were published. It never replaces compile or Runtime status.

`UAngelscriptEditorToolSettings` uses `Config=EditorPerProjectUserSettings` with C++ defaults:

- enabled: true
- SourceIds: 100
- revisions per source: 50
- compile attempts per source: 100
- run summaries per source: 100
- total root size: 256 MiB

Clamp loaded settings to finite ranges:

- SourceIds: 1-1000
- revisions: 1-500
- attempts: 1-1000
- runs: 1-1000
- root MiB: 16-4096

Public recovery types expose data only:

- Recent source summary: SourceId, ToolClassName, latest activity time, latest RevisionId and last-known-good RevisionId.
- Revision summary: SourceId, RevisionId, ToolClassName, source byte count, created time and whether it is last-known-good.
- Loaded revision: summary plus exact SourceText.
- `FAngelscriptToolHistorySourceListResult`: History result plus recent source summaries.
- `FAngelscriptToolHistoryRevisionListResult`: History result plus revision summaries.
- `FAngelscriptToolHistoryLoadResult`: History result, found flag and loaded revision.
- Each list/load result includes bounded history diagnostics and never contains a runner, UClass or UObject state.

`UAngelscriptEditorToolHistoryLibrary` exposes:

- `ListRecentSources(int32 Limit)`
- `ListRevisions(const FString& SourceId, int32 Limit)`
- `LoadRevision(const FString& SourceId, const FString& RevisionId)`
- `LoadLastKnownGood(const FString& SourceId)`
- `RebuildToolHistoryIndex()`
- `ForgetToolHistory(const FString& SourceId)`

List limits are 1-200. Load/list/rebuild return data only. None accepts a Runner, UClass or ContextObject.

## Tool History Storage Contract

### Root and identities

Use `FPaths::ProjectSavedDir()/Angelscript/ToolHistory/v1`. Never append raw SourceId to a filesystem path.

`Sources/<source-key>/` uses the lowercase 64-hex project-standard BLAKE3 of exact canonical SourceId UTF-8. RevisionId uses `FAngelscriptArtifactCanonicalWriter` domain `as-tool-history-revision-v1` over SourceId, ToolClassName and exact SourceText. AttemptId and RunId are lowercase 32-hex GUIDs; UTC timestamps in records define chronology, with ID as the deterministic tie-break.

Validate every incoming/generated ID before path construction:

- source and revision keys: exactly 64 lowercase hex;
- attempt/run IDs: exactly 32 lowercase hex;
- recomputed record identity equals directory/file identity;
- normalized absolute target remains beneath the exact v1 root.

### Layout

```text
Saved/Angelscript/ToolHistory/v1/
  index.json
  Sources/<source-key>/
    manifest.json
    Revisions/<revision-id>.json
    Attempts/<attempt-id>.json
    Runs/<run-id>.json
```

Every JSON object includes `schemaVersion=1`, record kind, canonical SourceId and its own identity. Records use UTF-8 without BOM.

Fixed read/write size caps:

- revision record: 2 MiB
- attempt record: 4 MiB
- run record: 256 KiB
- source manifest: 8 MiB
- root index: 4 MiB
- public history diagnostic/warning text: 64 KiB UTF-8 per entry

Oversized, malformed, unsupported-schema or identity-mismatched records are inert and reported; source text from them never reaches the preprocessor.

### Atomic publication

Use the established same-directory pattern:

1. Serialize the complete destination JSON.
2. Write `<destination>.tmp-<guid>` with `FFileHelper::SaveStringToFile(...ForceUTF8WithoutBOM)`.
3. Publish with `IFileManager::Move(destination, temporary, true, true)`.
4. Publish immutable record first, then source manifest, then root index.
5. On failure, delete only the exact staged temporary file and do not advance a pointer record.

Readers ignore `.tmp-` files and forget/retention tombstones. Index absence/corruption is reported; only explicit `RebuildToolHistoryIndex` scans validated source manifests.

### Journal and attempt sequence

For a valid recording compile request:

1. Compute/reuse RevisionId.
2. Publish the immutable revision if absent.
3. Publish manifest/index visibility before preprocessing, giving crash-recoverable source journaling.
4. Run preprocessing/compile/class validation regardless of journal success.
5. If compilation was reached and RevisionId is available, publish one unique attempt with bounded diagnostics.
6. Update last-known-good only when exact valid tool class resolution succeeds.

Identical source reuses its revision record but still creates a new attempt. Pre-validation failures create nothing.

### Retention

Create a deterministic eviction plan from validated metadata before pointer publication:

- Per-source records sort oldest first by UTC time, then ID.
- Protect the newest revision and retained last-known-good revision while the source remains indexed.
- Remove oldest eligible per-source revisions/attempts/runs first.
- When source-count or global bytes still exceed limits, evict least-recently-recorded SourceId first; never evict the SourceId currently being recorded.
- Publish manifests/index that stop referencing evicted records before moving those exact records/directories to store-owned tombstones and deleting them.
- If protected/current data cannot fit, return `CapacityExceeded` and preserve the prior published history. Compile/run truth is unchanged.

Count all regular files under v1 toward the byte limit. Bounded maintenance may delete only store-owned temporary/tombstone names older than 24 hours; a failed cleanup is a warning, not license to traverse outside the root.

### Exact forget

`ForgetToolHistory`:

1. Validate SourceId and derive the exact source key.
2. Return `NotFound` if neither validated index entry nor exact source directory exists.
3. Atomically move the source directory to a same-parent `.forget-<source-key>-<guid>` tombstone.
4. Publish root index removal.
5. If index publication fails, restore the directory when possible and return the publication failure.
6. Delete the tombstone. If deletion fails, return `DeleteFailed`; the ignored tombstone remains inert for maintenance.

This operation never touches the active AS module, generated UClass, runner map, user script roots or any other SourceId. Do not expose a reflected clear-all API.

## Execution Tasks

### Task 1: Runtime runner red tests

Files:

- Create `AngelscriptToolRunnerTestTypes.h/.cpp`.
- Create `AngelscriptToolRunnerTests.cpp`.

Write failing cases before production code:

- explicit owner factory and no singleton/fallback;
- same runner/class/default key reuse;
- isolation across runner/class/key;
- stable SessionId, exact reset, reset-all and removed-class reset;
- 256-session admission boundary;
- invalid/abstract/deprecated class;
- invalid/oversized arguments and response;
- tool-declared failure;
- same-session Busy and different-session nesting;
- off-thread rejection;
- ContextObject world binding/GetWorld, null/self context, context switching and restoration;
- AS reflected exception versus ordinary tool failure;
- runner/session GC retention and release;
- reflected types present with Test/Shipping execution disabled.

Run the prefix and preserve the expected failing evidence before Task 2.

### Task 2: Runtime implementation

Files:

- Create Runtime Tooling files and reflected-call capture files.
- Modify only the necessary ClassGenerator dispatch helper.

Implement in validation order, then make the native tests green. Add inline AS fixtures only after the native contract passes. Confirm exception capture works through the actual generated AS override and does not alter existing logging.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-tool-runtime -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Tooling.StatefulToolRunner' -Label as-tool-runner -TimeoutMs 600000
```

### Task 3: Editor source red tests and implementation

Files:

- Create `AngelscriptEditorToolSource.h/.cpp`.
- Create `AngelscriptEditorToolSourceTests.cpp`.

Write red cases for all input bounds, stable identity, compile-only no-dispatch, exact module-local class resolution, compile once/run many, last-known-good observation, diagnostics truncation, any-runner active-dispatch Busy and failed composition no-run. Implement with the existing `FAngelscriptSource`/preprocessor/`CompileModules(FullReload)` path.

Do not create disk fixtures under `Script/`. Use test-owned inline full source and unique bounded SourceIds; explicitly reset runner sessions during cleanup but do not claim module unload.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-editor-tool-source -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolExecution' -Label as-editor-tool-source -TimeoutMs 600000
```

### Task 4: Hot Run and logical-session tests

Extend `AngelscriptEditorToolSourceTests.cpp`:

- body-only update: same module, same physical UObject, preserved fields, new behavior;
- compatible structural update: physical UObject may change, SessionId stays stable, compatible UPROPERTY state migrates;
- compile failure: attempted source never runs, previous session is not reset, active class is reported;
- rename/removal/incompatible update: no migration guarantee, old string SessionId remains exactly resettable;
- reset: new object on next run without module unload;
- bounded reusable SourceId documentation assertion, not GUID/timestamp generation.

Run Snippet regression immediately after these cases because both surfaces use memory virtual paths but have intentionally different identity/lifetime.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolExecution' -Label as-editor-tool-reload -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Core.SnippetExecution' -Label as-snippet-regression -TimeoutMs 600000
```

### Task 5: History store red tests

Files:

- Create history types/store/library files.
- Create `AngelscriptEditorToolHistoryTests.cpp`.

Give the internal store a test-only constructor seam for:

- an explicit temporary root beneath the test workspace;
- a deterministic UTC clock;
- a fixed settings snapshot;
- failure injection at stage-write, publish, index and delete boundaries.

The public library always constructs the store with ProjectSavedDir and real UTC time. The seam is not reflected and cannot redirect production callers.

Write red tests for:

- root containment and BLAKE3 keys;
- record/schema/identity/size validation;
- source journal published before a simulated compile boundary;
- identical revision dedupe and distinct attempts;
- default/None/settings-disabled policy;
- no writes from Runtime, Snippet, disk compile or global compilation events;
- optional data-minimized run summary;
- atomic record/manifest/index order and stale temporary files;
- exact default retention, tie-breaking and protected records;
- capacity failure independent from compile/run truth;
- corrupt/missing/oversized records and explicit rebuild;
- bounded newest-first lists and inert exact load;
- exact tombstone forget, restore-on-index-failure and active module/session non-interference.

### Task 6: History implementation and Editor wiring

Implement the pure store first until its unit cases pass. Then wire source operations:

- compile request journals revision after validation;
- compile result records attempt and successful last-known-good;
- run operations record only explicit summary policy;
- nested compile/run results preserve independent history status;
- every filesystem error becomes History status/warning only.

Checkpoint:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-tool-history -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHistory' -Label as-tool-history -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolExecution' -Label as-tool-history-integration -TimeoutMs 600000
```

### Task 7: Documentation

Update the Chinese guide first with:

- runner-scoped multiton, explicitly not a singleton;
- a user-owned Editor subsystem retaining a Runner;
- running a normal already-loaded user tool class;
- compile-only, run-many and compile-and-run temporary source examples;
- explicit ContextObject and null-world behavior;
- logical versus physical identity during body/structural reload;
- failed update and explicit last-known-good run;
- Saved recovery list/load/resubmit flow;
- exact reset, exact forget and their different effects;
- no saved arguments/payload/context/UObject state;
- trusted code/no sandbox and no deterministic cleanup callback;
- Test/Shipping restriction and Development structural restart.

Then add the concise English README summary. Do not create an example product tool file; documentation snippets remain user-authored examples only.

### Task 8: Final verification and handoff

Run from the parent repository:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-tool-execution -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Tooling.StatefulToolRunner' -Label as-tool-runner-final -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolExecution' -Label as-editor-tool-final -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHistory' -Label as-tool-history-final -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Core.SnippetExecution' -Label as-snippet-final -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-tool-smoke -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunPackage.ps1 -Configuration Development -Label as-tool-development -TimeoutMs 3600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunPackage.ps1 -Configuration Shipping -Label as-tool-shipping -TimeoutMs 3600000
openspec validate feature-as-stateful-tool-execution --type change --strict --no-interactive
```

Inspect both repository diffs:

- no unrelated dirty-worktree edits included;
- no Runtime Editor/Settings dependency;
- no product `.as` files, registry, global runner, UI, scan, transport or unload;
- history root is only `Saved/Angelscript/ToolHistory/v1`;
- all public list inputs and persisted/read strings are bounded;
- compile/run status is never overwritten by history status;
- no broad reflected history deletion entry exists.

Record command outputs in a separate OpenSpec verification note, not in `tasks.md`. Mark checkboxes complete only after corresponding evidence exists.

## Acceptance Gate

- The user owns every tool class/source, trigger, presentation, runner lifetime and choice to recover/resubmit history.
- One runner/class/key is one logical session; it is not a singleton and is not restored after restart.
- Explicit ContextObject reaches tool GetWorld and world-sensitive AS bindings without Editor/PIE guessing or recursion.
- AS exceptions, invalid framework data and tool-declared failure have distinct structured statuses.
- Editor can compile without running, run active source without compiling and compose the two only on successful attempted source.
- Failed source never silently runs last-known-good; the caller must explicitly choose RunCompiledTool.
- Body-only versus structural reload documents physical identity honestly and tests only existing supported guarantees.
- Source journal/history is bounded, data-minimized, atomically published, fail-closed on read and independent from execution truth.
- Exact forget affects only recoverable history; exact reset affects only one runner session; neither unloads the module.
- Runtime behavior remains passive and persistence-free; Editor-only code is absent from non-Editor targets.
- Immediate Snippet behavior and its regressions remain unchanged.
