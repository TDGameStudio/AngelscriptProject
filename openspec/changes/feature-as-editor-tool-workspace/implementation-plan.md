# AngelScript Editor Tool Workspace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:test-driven-development` task-by-task and follow `.agents/skills/_angelscript-test-guide/SKILL.md`. Use `superpowers:executing-plans` for inline execution unless the user explicitly requests delegated/subagent work.

**Goal:** Build one official dockable scratch workspace that consumes the stateful tool runner, Editor Tool History and Editor tool-host context APIs while leaving permanent tool ownership to the user.

**Architecture:** A native Editor subsystem owns one workspace-scoped runner and bounded document controller. The controller talks to the lower-level reflected APIs through a mockable backend; a separate atomic draft store recovers unsubmitted source, and a Slate widget renders only the controller view model. Tool History remains authoritative for submitted revisions, while export transfers exact source into a user-chosen `.as` file.

**Tech Stack:** Unreal Editor/Slate/ToolMenus/DesktopPlatform (repository guidance baseline 5.7; current dirty checkout and local EngineRoot 5.8), `UAngelscriptToolRunner`, `UAngelscriptEditorToolLibrary`, `UAngelscriptEditorToolHistoryLibrary`, `UAngelscriptEditorToolContext`, JSON, CQTest/UE Automation.

## Global Constraints

- This plan has two implementation prerequisites: `feature-as-stateful-tool-execution` and `feature-as-editor-tool-host-extensions`. Do not create compatibility copies if their headers are absent; implement those changes first.
- Do not normalize the existing engine-version edits as part of this change: `AGENTS.md` describes a 5.7 baseline while the current user-owned `AngelscriptProject.uproject` and `AgentConfig.ini` select 5.8. Recheck the actual target at implementation time and build against it.
- Work in the current checkout. Do not create a worktree unless the user explicitly asks.
- Preserve unrelated parent and `Plugins/Angelscript` submodule changes. Commit only scoped files if/when commit authority is given.
- All workspace UI, subsystem, draft, export and settings code belongs to `AngelscriptEditor`. Runtime receives no Slate, UnrealEd, Settings, DesktopPlatform or Saved dependency.
- Keep `/Angelscript/Memory/Immediate/` Snippet behavior unchanged. Workspace source uses only the stable `/Angelscript/Memory/Tools/<SourceId>.as` API from the prerequisite.
- No tool discovery, `Script/Tools` convention, built-in tool scripts, async execution, Stop/Cancel, progress protocol, Output Log scraping or private Tool History JSON access.
- Drafts and Tool History are different stores. Drafts persist unsubmitted buffer state only; Tool History persists explicitly submitted revisions/attempts/optional run summaries.
- Never persist ArgumentsJson, PayloadJson, ContextObject, selected object paths or runner/tool UObject fields.
- Use test-owned temporary directories through explicit non-reflected seams. Production draft paths always resolve under `ProjectSavedDir/Angelscript/ToolWorkspace/v1`.
- Update Chinese documentation before the English README.

---

## Dependency Gate

Before editing implementation files, verify these prerequisite public headers exist and read their final signatures:

```text
Source/AngelscriptRuntime/Tooling/AngelscriptToolRunner.h
Source/AngelscriptEditor/Tooling/AngelscriptEditorToolSource.h
Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryTypes.h
Source/AngelscriptEditor/Tooling/AngelscriptEditorToolHistoryLibrary.h
Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolContext.h
Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolHostRegistry.h
```

Required behavior, even if final UHT syntax differs:

- compile-only, run-compiled and compile-and-run have separate structured results;
- failed compile never implicitly dispatches last-known-good;
- exact SessionId reset is available;
- history list/load is bounded and data-only;
- context capture takes an explicit Owner and returns one transient snapshot;
- the host registry exposes its AngelScript Tools workspace group to native Editor consumers.

If a prerequisite changed these semantics, stop and revise this OpenSpec with the user. If only a reflected spelling changed, update the concrete names in this plan before implementing.

## File Map

| Repository | Path | Responsibility |
|---|---|---|
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceTypes.h` | Document state, immutable view model, action availability and result presentation types. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceSettings.h/.cpp` | Editor-per-project-user run-summary setting, default false. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceBackend.h/.cpp` | Mockable adapter around context, compile/run/reset and public history APIs. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceController.h/.cpp` | Bounded document validation and explicit operation state machine. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceDraftStore.h/.cpp` | Validated atomic draft/index storage, retention, recovery and exact forget. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceExporter.h/.cpp` | User-directed platform save dialog and atomic UTF-8 `.as` publication. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceSubsystem.h/.cpp` | Explicit workspace runner owner, controller owner and two-second draft-save scheduler. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/SAngelscriptToolWorkspace.h/.cpp` | Dock-tab presentation, source editor, commands and lower result/recovery panes. |
| Plugin | `Source/AngelscriptEditor/ToolWorkspace/AngelscriptToolWorkspaceRegistration.h/.cpp` | Nomad-tab and Tools-menu registration using the host registry workspace group. |
| Plugin | `Source/AngelscriptEditor/Core/AngelscriptEditorModule.h/.cpp` | Own/start/stop workspace registration after host initialization. |
| Plugin | `Source/AngelscriptEditor/AngelscriptEditor.Build.cs` | Add private `DesktopPlatform`; reuse existing Slate, ToolMenus, PropertyEditor, Json and Settings dependencies. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptToolWorkspaceControllerTests.cpp` | Validation/state/compile/run/context/history-policy tests with fake backend. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptToolWorkspaceDraftStoreTests.cpp` | Pure draft schema/atomicity/retention/recovery/forget tests. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptToolWorkspaceExporterTests.cpp` | Dialog/path/content/atomic-failure tests. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptToolWorkspaceSubsystemTests.cpp` | Runner/subsystem/tab-close/autosave lifecycle tests. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptToolWorkspaceRegistrationTests.cpp` | Tab/menu/headless/duplicate registration tests. |
| Parent | `Documents/Knowledges/ZH/Guide_EditorExtension.md` | Chinese-first workflow, safety and storage documentation. |
| Plugin | `README.md` | Concise English consumer summary. |

## Core Types and Interfaces

Use these exact semantic fields; adapt syntax only where final prerequisite headers require it.

```cpp
enum class EAngelscriptToolWorkspaceDocumentState : uint8
{
	Draft,
	Compiling,
	CompileFailed,
	Ready,
	Running,
	RunFailed,
};

struct FAngelscriptToolWorkspaceDocument
{
	FString DocumentId;             // exactly 32 lowercase hex
	FString SourceId;
	FString ToolClassName;
	FString SourceText;
	FName SessionKey = TEXT("Default");
	FString LastSubmittedRevisionId;
	FString ActiveRevisionId;
	FAngelscriptToolSessionId LastSessionId;
	EAngelscriptToolWorkspaceDocumentState State =
		EAngelscriptToolWorkspaceDocumentState::Draft;
	bool bDirty = true;
	bool bHasLastKnownGood = false;
	FDateTime LastEditedAtUtc;
};

struct FAngelscriptToolWorkspaceViewModel
{
	TArray<FString> DocumentIds;
	FString ActiveDocumentId;
	EAngelscriptToolWorkspaceDocumentState State;
	bool bCanCompile = false;
	bool bCanRunActive = false;
	bool bCanCompileAndRun = false;
	bool bCanRunLastKnownGood = false;
	bool bCanResetSession = false;
	bool bCanSwitchDocument = false;
	TArray<FAngelscriptToolCompileDiagnostic> Diagnostics;
	FString AttemptedRevisionId;
	FString ActiveRevisionId;
	FString OperationMessage;
	TArray<FString> IndependentWarnings;
};
```

ArgumentsJson is an ephemeral widget/controller call parameter, not a field in `FAngelscriptToolWorkspaceDocument` or any draft type.

```cpp
class IAngelscriptToolWorkspaceBackend
{
public:
	virtual ~IAngelscriptToolWorkspaceBackend() = default;
	virtual FAngelscriptEditorToolContextCaptureResult CaptureContext(UObject* Owner) = 0;
	virtual FAngelscriptEditorToolCompileResult Compile(
		const FAngelscriptEditorToolCompileRequest& Request) = 0;
	virtual FAngelscriptEditorToolRunResult Run(
		const FAngelscriptEditorToolRunRequest& Request) = 0;
	virtual FAngelscriptEditorToolCompileAndRunResult CompileAndRun(
		const FAngelscriptEditorToolCompileAndRunRequest& Request) = 0;
	virtual bool ResetSession(
		UAngelscriptToolRunner* Runner,
		const FAngelscriptToolSessionId& SessionId) = 0;
	virtual FAngelscriptToolHistorySourceListResult ListRecentSources(int32 Limit) = 0;
	virtual FAngelscriptToolHistoryRevisionListResult ListRevisions(
		const FString& SourceId, int32 Limit) = 0;
	virtual FAngelscriptToolHistoryLoadResult LoadRevision(
		const FString& SourceId, const FString& RevisionId) = 0;
	virtual FAngelscriptToolHistoryLoadResult LoadLastKnownGood(
		const FString& SourceId) = 0;
};
```

Production backend delegates directly to the prerequisite libraries. It has no filesystem access to Tool History and no log listener.

```cpp
UCLASS(Config=EditorPerProjectUserSettings)
class ANGELSCRIPTEDITOR_API UAngelscriptToolWorkspaceSettings : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, Config, Category="History")
	bool bRecordDataMinimizedRunSummaries = false;
};

UCLASS(Transient)
class ANGELSCRIPTEDITOR_API UAngelscriptToolWorkspaceSubsystem : public UEditorSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;

	UAngelscriptToolRunner* GetRunner() const { return Runner; }
	FAngelscriptToolWorkspaceController& GetController();

private:
	UPROPERTY(Transient)
	TObjectPtr<UAngelscriptToolRunner> Runner;
	TUniquePtr<FAngelscriptToolWorkspaceController> Controller;
	TUniquePtr<FAngelscriptToolWorkspaceDraftStore> DraftStore;
	FDelegateHandle AutosaveTickerHandle;
};
```

The subsystem is a host, not a new runner factory. It must call `UAngelscriptToolLibrary::CreateRunner(this)` exactly once per subsystem initialization.

## Draft Storage Contract

Physical layout:

```text
Saved/Angelscript/ToolWorkspace/v1/
  index.json
  Drafts/<document-id>.json
```

Draft JSON fields:

```json
{
  "schemaVersion": 1,
  "kind": "workspace-draft",
  "documentId": "0123456789abcdef0123456789abcdef",
  "sourceId": "Scratch/CurrentTool",
  "toolClassName": "UCurrentScratchTool",
  "sourceText": "...",
  "sessionKey": "Default",
  "lastSubmittedRevisionId": "",
  "activeRevisionId": "",
  "dirty": true,
  "lastEditedAtUtc": "2026-08-13T00:00:00.000Z",
  "savedAtUtc": "2026-08-13T00:00:02.000Z"
}
```

Never add arguments, payload, diagnostic arrays, ContextObject, selected names/paths or serialized UObject properties.

Production limits:

- 20 drafts;
- 1 MiB UTF-8 source per draft;
- 2 MiB per draft record;
- 4 MiB index;
- 32 MiB total root.

Publication order: draft temporary → draft destination → index temporary → index destination. A failed draft publication does not advance the index. A failed index publication leaves the complete draft unreferenced; explicit bounded rebuild on next workspace open may index only validated draft files. Readers ignore `.tmp-` and `.forget-` names.

## Task 1: Dependency verification and controller state red tests

**Files:**

- Create `AngelscriptToolWorkspaceTypes.h`.
- Create `AngelscriptToolWorkspaceBackend.h/.cpp`.
- Create `AngelscriptToolWorkspaceController.h/.cpp`.
- Create `AngelscriptToolWorkspaceControllerTests.cpp`.

**Interfaces:** Produces the backend/controller/view model consumed by subsystem and UI.

- [ ] Read the prerequisite headers and replace any syntax-only name drift in this plan. Do not proceed if compile/run/context semantics differ.
- [ ] Implement a test fake backend that records every call and can enqueue exact structured results. It must fail a test if the controller calls an unexpected method.
- [ ] Write a red CQTest class under `Angelscript.Editor.ToolWorkspace.Controller` with scenario methods for New Draft, invalid/duplicate SourceId, 20-document admission, 1 MiB UTF-8 bound and SessionKey normalization.
- [ ] Write the state transition table as assertions:

  ```text
  Draft --Compile(success)--------> Ready
  Draft --Compile(failure)--------> CompileFailed
  Draft --CompileAndRun(success)--> Ready
  Ready --Run(failure)------------> RunFailed
  Ready --Run(success)------------> Ready
  any idle --operation active-----> Busy for re-entry
  ```

- [ ] Run:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolWorkspace.Controller' -Label as-tool-workspace-controller-red -TimeoutMs 600000
  ```

  Expected before implementation: FAIL because the controller does not exist.

- [ ] Implement document validation by reusing the public compile request validator where exposed; otherwise mirror only UI preflight and let the backend remain authoritative. Never fork module-name derivation.
- [ ] Generate DocumentId once as lowercase digits from `FGuid::NewGuid().ToString(EGuidFormats::Digits)`. Do not use it as SourceId.
- [ ] Derive all action booleans from document state and available structured identity; do not let Slate independently infer them.
- [ ] Re-run the controller prefix; expected validation/state methods PASS.

## Task 2: Compile run last-known-good context and reset

**Files:** Extend controller/backend/tests; create settings files.

- [ ] Red-test Compile: backend Compile called once with exact buffer/identity and `SourceAndDiagnostics`; backend Run/CompileAndRun not called; no session ID created.
- [ ] Red-test Run Active: CaptureContext called first, Run called once, Compile not called, exact runner/identity/key/arguments forwarded.
- [ ] Red-test Compile & Run: capture context once, composed call once, failed compile produces no secondary Run call, nested compile/run/history statuses preserved.
- [ ] Red-test failed compile with last-known-good: source buffer remains failed text; ordinary Compile & Run does not run; only explicit RunLastKnownGood calls Run with exact active identity.
- [ ] Red-test context failure: no run call and no mutation of active revision/session.
- [ ] Red-test Reset Session: only exact stored SessionId passed; document/history/draft source unchanged; unknown SessionId disables action.
- [ ] Implement operations with an RAII active-operation guard so every exception/early return restores an idle state and re-entry reports Busy.
- [ ] Add `UAngelscriptToolWorkspaceSettings` default false and tests:

  ```text
  Compile -> SourceAndDiagnostics
  Run with setting false -> None
  CompileAndRun with setting false -> SourceAndDiagnostics
  Run/CompileAndRun with setting true -> SourceDiagnosticsAndRunSummary
  ```

- [ ] Ensure ArgumentsJson exists only as an operation parameter and inside the immediate prerequisite request. Search production workspace types for `ArgumentsJson` and confirm it appears in no draft serialization code.
- [ ] Re-run the controller prefix; expected all operation methods PASS.

## Task 3: Draft store red tests and implementation

**Files:**

- Create `AngelscriptToolWorkspaceDraftStore.h/.cpp`.
- Create `AngelscriptToolWorkspaceDraftStoreTests.cpp`.

**Interfaces:** The store accepts an explicit root, clock and limits in non-reflected internal construction; production factory supplies ProjectSavedDir and fixed v1 limits.

- [ ] Build every test root beneath the test runner's temporary workspace. Resolve absolute root and assert it remains beneath that directory before cleanup.
- [ ] Write red tests for exact 32-lowercase-hex ID, schema/kind/identity match, UTF-8 size caps and field allowlist. Assert JSON does not contain `ArgumentsJson`, `PayloadJson`, `ContextObject`, selected object paths or diagnostic arrays.
- [ ] Write red atomic tests with failure injection at draft stage write, draft publish, index stage write and index publish. Assert readers never return partial JSON.
- [ ] Write red recovery tests for missing/corrupt index, malformed/oversized draft, unsupported schema, stale `.tmp-` and ignored `.forget-` paths.
- [ ] Write deterministic retention tests using a fake UTC clock: oldest LastEditedAtUtc then DocumentId tie-break; active document protected; capacity failure leaves published state intact.
- [ ] Implement contained path helpers. Never append an unchecked DocumentId or use SourceId in a physical filename.
- [ ] Serialize with `FJsonObject`/`FJsonSerializer`, force UTF-8 without BOM, stage in the destination directory and publish through `IFileManager::Move` replacement.
- [ ] Implement exact Forget Draft as destination → same-parent `.forget-<id>-<guid>` move, index removal publication, then tombstone delete; restore on index failure when possible.
- [ ] Implement bounded rebuild during explicit workspace-open recovery only. It scans at most 20 eligible validated draft filenames plus bounded ignored entries and performs no compilation.
- [ ] Run:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolWorkspace.Drafts' -Label as-tool-workspace-drafts -TimeoutMs 600000
  ```

  Expected: all draft tests PASS.

## Task 4: History consumer and export

**Files:**

- Extend controller/backend/tests.
- Create `AngelscriptToolWorkspaceExporter.h/.cpp`.
- Create `AngelscriptToolWorkspaceExporterTests.cpp`.
- Modify Build.cs to add private `DesktopPlatform`.

- [ ] Red-test history calls: recent limit exactly 100; revision limit exactly 50; selection metadata alone causes no Load/Compile/Run; LoadRevision creates/replaces only after dirty-buffer choice.
- [ ] Expose explicit controller outcomes `Cancelled`, `LoadedIntoCurrent`, `CreatedNewDraft`, `CapacityExceeded` for dirty replacement choices; never bury the choice in Slate callbacks.
- [ ] Implement public history calls solely through the backend. Add a static source scan test asserting workspace production files contain no `ToolHistory/v1`, `manifest.json`, `Attempts/` or `Runs/` parser.
- [ ] Define an exporter platform seam:

  ```cpp
  class IAngelscriptToolWorkspaceExportPlatform
  {
  public:
      virtual bool ChooseSavePath(FString& OutPath) = 0;
      virtual bool WriteUtf8Atomically(
          const FString& Destination,
          const FString& ExactSource,
          FString& OutError) = 0;
  };
  ```

- [ ] Red-test cancellation, missing/wrong extension, exact current buffer, exact loaded revision, overwrite-confirmed destination, stage failure and publish failure.
- [ ] Production ChooseSavePath uses DesktopPlatform's save dialog with `.as` filter and existing `ProjectDir/Script` only as an initial directory when it exists. It must not create that directory.
- [ ] Production write stages beside the confirmed destination, saves UTF-8 without BOM, atomically replaces it and deletes only its exact temporary path on failure.
- [ ] Add a test hook proving exporter success never calls Compile/CompileAndRun or the directory watcher directly.
- [ ] Run History/Exporter controller methods; expected PASS.

## Task 5: Subsystem lifecycle and autosave

**Files:**

- Create subsystem files and `AngelscriptToolWorkspaceSubsystemTests.cpp`.

- [ ] Red-test initialization calls `CreateRunner(this)` exactly once and retains the returned runner in a reflected transient property.
- [ ] Red-test closing the visible tab does not deinitialize the subsystem or reset sessions; subsystem Deinitialize cancels autosave, flushes the active draft once, resets/releases the runner and destroys controller/store in safe order.
- [ ] Give the subsystem a test clock/ticker seam. Red-test autosave becomes eligible only after two seconds without source edit, coalesces repeated edits and never overlaps a synchronous compile/run operation.
- [ ] Implement the controller owner and draft save scheduler. The ticker schedules storage only; it never ticks/runs user AngelScript tools.
- [ ] On draft failure, add one independent warning to the view model and leave compile/run action availability unchanged.
- [ ] Run:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolWorkspace.Subsystem' -Label as-tool-workspace-subsystem -TimeoutMs 600000
  ```

## Task 6: Slate workspace and registration

**Files:**

- Create `SAngelscriptToolWorkspace.h/.cpp`.
- Create `AngelscriptToolWorkspaceRegistration.h/.cpp`.
- Create `AngelscriptToolWorkspaceRegistrationTests.cpp`.
- Modify Editor module header/cpp.

**Interfaces:** Slate reads view models and calls controller commands. It does not call compile/history files directly.

- [ ] Build the UI in this fixed hierarchy:

  ```text
  Document selector | SourceId | ToolClassName | SessionKey
  Compile | Run Active | Compile & Run | [Run Last Known Good] | Reset | Export
  Multi-line monospaced source editor
  Diagnostics | Result | Context | Recovery/History
  ```

- [ ] Bind source changes to controller dirty/edit time and subsystem autosave scheduling. Keep ArgumentsJson in the live widget only and clear it when the physical tab is destroyed.
- [ ] Bind action enabled/visibility solely from the view model. There is no Stop/Cancel action or hidden keyboard command.
- [ ] Diagnostics selection moves caret only when diagnostic virtual path matches the current document path and row/column are in range.
- [ ] Result pane renders attempted/active revision, active class, Runtime status, independent history warning and independent draft warning separately.
- [ ] Context pane renders world name, PIE/SIE, counts and truncation only; never enumerate/save the full selected object set in output text.
- [ ] Register one `Angelscript.ToolWorkspace` nomad tab using the host registry's shared AngelScript Tools workspace group. Register a Tools-menu entry under the Editor module's existing owner.
- [ ] Resolve `UAngelscriptToolWorkspaceSubsystem` from GEditor when spawning. If unavailable, show a non-executing error surface rather than creating a second runner.
- [ ] Add test adapters for global tab manager, ToolMenus and subsystem resolution. Red/green tests for singleton focus, layout restoration, headless inertness and idempotent unregister.
- [ ] In `FAngelscriptEditorModule`, initialize workspace registration after tool-host registry and shut it down before the host registry. Keep the Snippet action/override untouched.

## Task 7: Documentation and final verification

**Files:**

- Modify Chinese guide first.
- Modify plugin README second.

- [ ] Document the user flow: New/Recover → edit → Compile → repeat Run Active → explicit Last Known Good → Reset → Export.
- [ ] State three independent lifetimes: draft source across restart, Tool History submitted revisions, runner UObject state only in the current Editor process.
- [ ] State that run-summary recording defaults off and omits context/arguments/payload/object fields when enabled.
- [ ] State that execution is trusted synchronous local code with no Stop/cancel/sandbox; long-running tools block the Editor.
- [ ] State that export has no managed directory and normal watcher behavior applies after the file appears.
- [ ] Run final verification:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-editor-tool-workspace -TimeoutMs 1800000 -NoXGE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolWorkspace' -Label as-editor-tool-workspace -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolExecution' -Label as-tool-execution-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHistory' -Label as-tool-history-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHost' -Label as-tool-host-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Core.SnippetExecution' -Label as-snippet-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.Module.Menu' -Label as-editor-menu-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-editor-tool-workspace-smoke -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunPackage.ps1 -Configuration Development -Label as-tool-workspace-development -TimeoutMs 3600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunPackage.ps1 -Configuration Shipping -Label as-tool-workspace-shipping -TimeoutMs 3600000
  openspec validate feature-as-editor-tool-workspace --type change --strict --no-interactive
  ```

- [ ] Inspect parent and submodule diffs. Confirm no Runtime editor dependency, product `.as` tool, tool catalogue, direct Tool History parser, persisted arguments/context/payload, Stop/cancel action, source-root creation or unrelated dirty edit entered the change.
- [ ] Record exact pass counts and report/package paths in `openspec/changes/feature-as-editor-tool-workspace/verification.md`; keep `tasks.md` commentary-free.

## Acceptance Gate

- The workspace is one official UI consumer, not the owner of every project tool.
- Compile, Run Active, Compile & Run, Run Last Known Good and Reset have distinct behavior and structured results.
- Failed submitted source is never silently replaced or executed as previous code.
- Every execution captures current editor context explicitly; context and ArgumentsJson never enter draft/history persistence.
- Draft recovery is bounded, atomic and inert; Tool History remains the only submitted-revision store.
- Export writes exact selected source to a user-chosen `.as` path and establishes no plugin folder convention.
- Closing the tab preserves the workspace-hosted process session; restarting the Editor never restores UObject state.
- Existing Snippet, menu and non-Editor builds remain unchanged.
