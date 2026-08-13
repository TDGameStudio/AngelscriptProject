# AngelScript Editor Tool Host Extensions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:test-driven-development` task-by-task and follow `.agents/skills/_angelscript-test-guide/SKILL.md`. Use `superpowers:executing-plans` for inline execution unless the user explicitly requests delegated/subagent work.

**Goal:** Add explicit editor-context snapshots, keyboard-bindable script command declarations and Details-hosted script dock tabs without creating a tool catalogue or changing Runtime.

**Architecture:** `AngelscriptEditor` owns one native host registry attached to the existing AngelScript engine lifecycle. Public UObjects define the script-facing context/command/tab contracts; focused native services adapt them to Level Editor commands, the global tab manager and PropertyEditor. Tab properties use `IDetailsView`, while eligible zero-parameter `CallInEditor` methods use an explicit native action section. Every command execution and tab session has explicit transient UObject ownership.

**Tech Stack:** Unreal Editor APIs (repository guidance baseline 5.7; current dirty checkout and local EngineRoot 5.8), AngelScript generated UClasses, `FUICommandInfo`, `FUICommandList`, `FGlobalTabmanager`, `IDetailsView`, ToolMenus, CQTest/UE Automation.

## Global Constraints

- Work in the current checkout; do not create a worktree unless the user later asks.
- Do not normalize the existing engine-version edits as part of this change: `AGENTS.md` describes a 5.7 baseline while the current user-owned `AngelscriptProject.uproject` and `AgentConfig.ini` select 5.8. Recheck the actual target at implementation time and build against it.
- `Plugins/Angelscript` is a submodule. Preserve its unrelated live diff and commit submodule changes before the parent gitlink only if commit authority is given.
- All implementation remains in `AngelscriptEditor`; do not add a Runtime type, dependency, global runner or persistence path.
- Do not scan disk roots or ordinary `UAngelscriptTool` classes. Discovery is restricted to concrete loaded subclasses of the two explicit host bases.
- Context collections are capped at 4096 entries each. CommandName/TabName are explicit stable IDs, not class-path hashes.
- The tab UI is a standard Details view plus an explicit reflected-action section. Do not add arbitrary Slate/UMG/Editor Utility Widget hosting in v1.
- Command instances are per invocation; tab instances are per physical open tab; neither is a process singleton.
- Use `TEST_CLASS_WITH_FLAGS` and scenario-specific `TEST_METHOD`s. Place Editor internals under `AngelscriptEditor/Tests` and inline AS integration under `AngelscriptTest/Editor`.
- Update the Chinese guide before the English README.

---

## File Map

| Repository | Path | Responsibility |
|---|---|---|
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolContext.h` | Reflected capture status/result/context/library declarations. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolContext.cpp` | Owner/thread validation and Level Editor/Content Browser point-in-time capture. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorCommandExtension.h` | Reflected chord and script command base. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorCommandExtension.cpp` | Base defaults and safe BlueprintNativeEvent implementations. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorTabExtension.h` | Script tab base and reflected tab-session owner. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorTabExtension.cpp` | Tab base/session lifecycle and context assignment. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolHostRegistry.h` | Native registry, registration snapshots and test access seams. |
| Plugin | `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolHostRegistry.cpp` | Class discovery, command mapping, tab spawning, Details/action view and reload reconciliation. |
| Plugin | `Source/AngelscriptEditor/Core/AngelscriptEditorModule.h` | Own one `TUniquePtr<FAngelscriptEditorToolHostRegistry>`. |
| Plugin | `Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp` | Initialize and shut down the registry in the existing Editor lifecycle. |
| Plugin | `Source/AngelscriptEditor/AngelscriptEditor.Build.cs` | Add explicit public `InputCore` dependency for reflected `FKey`. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptEditorToolHostTestTypes.h/.cpp` | UHT-visible command/tab fixtures and invocation observations. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptEditorToolContextTests.cpp` | Context owner/thread/selection/bounds/inertness tests. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptEditorCommandExtensionTests.cpp` | Command discovery/chord/execution/reload/shutdown tests. |
| Plugin | `Source/AngelscriptEditor/Tests/AngelscriptEditorTabExtensionTests.cpp` | Tab registration/session/Details/context/reload tests. |
| Plugin | `Source/AngelscriptTest/Editor/AngelscriptEditorToolHostScriptTests.cpp` | Inline AS subclass registration and callback integration. |
| Parent | `Documents/Knowledges/ZH/Guide_EditorExtension.md` | Chinese-first user contract and examples. |
| Plugin | `README.md` | Concise English consumer summary. |

Do not modify `Script/` or add product tool fixtures. All AS sources remain inline test/documentation strings.

## Public Contract

Use these names unless UHT compilation proves a syntax-only adjustment is required. Record any adjustment in the OpenSpec before continuing.

```cpp
UENUM(BlueprintType)
enum class EAngelscriptEditorToolContextCaptureStatus : uint8
{
	Succeeded,
	SucceededWithWarnings,
	InvalidOwner,
	WrongThread,
	EditorUnavailable,
};

UCLASS(BlueprintType, Transient)
class ANGELSCRIPTEDITOR_API UAngelscriptEditorToolContext : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	TObjectPtr<UWorld> EditorWorld;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	TArray<TObjectPtr<AActor>> SelectedActors;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	TArray<FAssetData> SelectedAssets;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	TArray<FName> SelectedFolders;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	bool bPlaySessionActive = false;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	bool bSimulatingInEditor = false;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	bool bActorsTruncated = false;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	bool bAssetsTruncated = false;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	bool bFoldersTruncated = false;

	UPROPERTY(BlueprintReadOnly, Transient, Category="AngelScript Tool Context")
	FDateTime CapturedAtUtc;

	virtual UWorld* GetWorld() const override;
};

USTRUCT(BlueprintType)
struct ANGELSCRIPTEDITOR_API FAngelscriptEditorToolContextCaptureResult
{
	GENERATED_BODY()

	UPROPERTY(BlueprintReadOnly)
	EAngelscriptEditorToolContextCaptureStatus Status =
		EAngelscriptEditorToolContextCaptureStatus::EditorUnavailable;

	UPROPERTY(BlueprintReadOnly)
	TObjectPtr<UAngelscriptEditorToolContext> Context;

	UPROPERTY(BlueprintReadOnly)
	FString Message;
};

UCLASS()
class ANGELSCRIPTEDITOR_API UAngelscriptEditorToolContextLibrary : public UObject
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, Category="AngelScript|Editor Tools")
	static FAngelscriptEditorToolContextCaptureResult
	CaptureCurrentEditorContext(UObject* Owner);
};
```

Clamp each selected category with a shared `constexpr int32 MaxContextItems = 4096`. Iterate `GEditor->GetSelectedActors()` without mutating it. Use `IContentBrowserSingleton::GetSelectedAssets` and `GetSelectedFolders`; keep `FAssetData` and do not call `GetAsset()`.

```cpp
USTRUCT(BlueprintType)
struct ANGELSCRIPTEDITOR_API FAngelscriptEditorCommandChord
{
	GENERATED_BODY()

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	FKey Key;
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	bool bCtrl = false;
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	bool bAlt = false;
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	bool bShift = false;
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly)
	bool bCmd = false;

	FInputChord ToInputChord() const;
};

UCLASS(Abstract, NotBlueprintable, Meta=(NoBlueprintsOfChildren))
class ANGELSCRIPTEDITOR_API UScriptEditorCommandExtension : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(EditDefaultsOnly, Category="Editor Command")
	FName CommandName;
	UPROPERTY(EditDefaultsOnly, Category="Editor Command")
	FText DisplayName;
	UPROPERTY(EditDefaultsOnly, Category="Editor Command", Meta=(MultiLine=true))
	FText Description;
	UPROPERTY(EditDefaultsOnly, Category="Editor Command")
	FName IconName;
	UPROPERTY(EditDefaultsOnly, Category="Editor Command")
	FAngelscriptEditorCommandChord DefaultChord;
	UPROPERTY(EditDefaultsOnly, Category="Editor Command")
	bool bAllowDuringPlaySession = false;

	UFUNCTION(BlueprintNativeEvent)
	bool ShouldRegister() const;
	UFUNCTION(BlueprintNativeEvent)
	bool CanExecute() const;
	UFUNCTION(BlueprintNativeEvent)
	void Execute(UAngelscriptEditorToolContext* Context);
};
```

The base ShouldRegister/CanExecute implementations return true; Execute is a no-op. Validate names before any FUICommand allocation. When a duplicate exists, emit one entry per conflicting class in sorted class-path order and register none.

```cpp
UCLASS(Abstract, NotBlueprintable, Meta=(NoBlueprintsOfChildren))
class ANGELSCRIPTEDITOR_API UScriptEditorTabExtension : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(EditDefaultsOnly, Category="Editor Tab")
	FName TabName;
	UPROPERTY(EditDefaultsOnly, Category="Editor Tab")
	FText DisplayName;
	UPROPERTY(EditDefaultsOnly, Category="Editor Tab")
	FText ToolTip;
	UPROPERTY(EditDefaultsOnly, Category="Editor Tab")
	FName IconName;
	UPROPERTY(BlueprintReadOnly, Transient, Category="Editor Tab")
	TObjectPtr<UAngelscriptEditorToolContext> CurrentContext;

	UFUNCTION(BlueprintNativeEvent)
	bool ShouldRegister() const;
	UFUNCTION(BlueprintImplementableEvent)
	void BP_Initialize(UAngelscriptEditorToolContext* Context);
	UFUNCTION(BlueprintImplementableEvent)
	void BP_ContextRefreshed(UAngelscriptEditorToolContext* Context);
	UFUNCTION(BlueprintImplementableEvent)
	void BP_Deinitialize();
};

UCLASS(Transient)
class ANGELSCRIPTEDITOR_API UAngelscriptEditorTabSession : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(Transient)
	TObjectPtr<UScriptEditorTabExtension> Extension;
	UPROPERTY(Transient)
	TObjectPtr<UAngelscriptEditorToolContext> Context;
	UPROPERTY(Transient)
	FName CanonicalTabId;
	UPROPERTY(Transient)
	bool bInitialized = false;
	UPROPERTY(Transient)
	bool bDeinitialized = false;
};
```

The registry keeps `TStrongObjectPtr<UAngelscriptEditorTabSession>` only while its tab is open. Never root the script extension directly. It also owns one shared `FWorkspaceItem` and exposes `TSharedRef<FWorkspaceItem> GetWorkspaceGroup() const` to native Editor-module consumers only.

## Task 1: Context capture red tests and implementation

**Files:**

- Create `Source/AngelscriptEditor/Tests/AngelscriptEditorToolContextTests.cpp`.
- Create `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolContext.h/.cpp`.

**Interfaces:** Produces the context API above for every later task.

- [ ] Write scenario-specific tests under `Angelscript.Editor.ToolHost.Context` for invalid owner, wrong thread, no GEditor, empty selection, combined selection and captured-world `GetWorld()`.
- [ ] Add test-only resolvers in the context `.cpp` for actor selection, asset/folder selection, editor world, PIE/SIE and UTC time. Production defaults must call real Editor APIs; reset every override with `ON_SCOPE_EXIT`.
- [ ] Run:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHost.Context' -Label as-editor-tool-context-red -TimeoutMs 600000
  ```

  Expected before implementation: FAIL because the public context types/capture do not exist.

- [ ] Implement validation in this order: Game Thread, Owner validity, GEditor availability, allocate transient context, capture world/play flags, copy capped actors, copy capped asset metadata, copy capped folders, return success/warnings.
- [ ] Add a 4097-entry fake source per category and assert count 4096 plus only the corresponding truncation flag.
- [ ] Change fake selection after capture and assert the old context remains unchanged; invalidate the captured world and assert `GetWorld()` returns null rather than another world.
- [ ] Re-run the prefix. Expected: all Context methods PASS with zero warnings/errors.

## Task 2: Command declaration and registry red tests

**Files:**

- Create `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorCommandExtension.h/.cpp`.
- Create `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolHostRegistry.h/.cpp`.
- Create `Source/AngelscriptEditor/Tests/AngelscriptEditorToolHostTestTypes.h/.cpp`.
- Create `Source/AngelscriptEditor/Tests/AngelscriptEditorCommandExtensionTests.cpp`.
- Modify `Source/AngelscriptEditor/AngelscriptEditor.Build.cs` to add `InputCore` to `PublicDependencyModuleNames`.

**Interfaces:** Registry consumes loaded UClasses and a platform adapter; produces command registration snapshots and execution callbacks. Later tab work extends the same registry.

- [ ] Define native fixtures: valid command, registration-declined command, invalid-name command, two duplicate-name commands, PIE-disallowed command and observation counters for CDO/instance callbacks.
- [ ] Give the registry a non-reflected test adapter with these exact operations: enumerate candidate classes, create/unregister command info, map/unmap action, test PIE/SIE, capture context and publish bounded diagnostic. Production implementation wraps Unreal APIs.
- [ ] Write discovery tests that sort candidates by class path, validate the explicit ID, reject both duplicates and ignore abstract/unrelated classes.
- [ ] Run `Angelscript.Editor.ToolHost.Commands`; expect red failures before registry implementation.
- [ ] Implement one binding context `AngelscriptEditorTools`. Create `FUICommandInfo` only after the complete duplicate set has been computed.
- [ ] Convert `FAngelscriptEditorCommandChord` to `FInputChord`. Preserve normal Unreal user binding overrides; if a default cannot be admitted, register unbound and record a warning.
- [ ] Map CanExecute to the CDO under `FEditorScriptExecutionGuard`. Do not allocate context or an instance during this query.
- [ ] Map Execute to: verify play-state gate, create transient instance, capture context with instance as Owner, call Execute once under guard, then release all native references.
- [ ] Assert two invocations create two object identities and two context identities; fields/counters on each instance start at defaults.
- [ ] Assert unavailable capture never invokes Execute and teardown remains idempotent.
- [ ] Re-run the prefix. Expected: all command tests PASS.

## Task 3: Tab declaration session and reflected host

**Files:**

- Create `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorTabExtension.h/.cpp`.
- Extend `Source/AngelscriptEditor/EditorToolHost/AngelscriptEditorToolHostRegistry.h/.cpp`.
- Extend `Source/AngelscriptEditor/Tests/AngelscriptEditorToolHostTestTypes.h/.cpp`.
- Create `Source/AngelscriptEditor/Tests/AngelscriptEditorTabExtensionTests.cpp`.

**Interfaces:** Registry tab adapter wraps global-tab-manager registration/invocation/closure and PropertyEditor Details creation. It produces one session per open canonical tab ID and exposes the shared native workspace group.

- [ ] Define fixtures for valid, declined, duplicate and incompatible tabs. Each valid fixture records Initialize, Refresh and Deinitialize counts and exposes one editable property plus one `CallInEditor` method.
- [ ] Extend the platform adapter with register/unregister spawner, request close, create Details view and refresh Details object operations. Keep real `SDockTab` construction in one focused private function.
- [ ] Write red tests for stable `AngelscriptEditorTools.<TabName>`, duplicate rejection and workspace grouping.
- [ ] Implement session creation with session Outer owned by the registry's transient owner, extension Outer set to session, context Outer set to session and exactly-once Initialize.
- [ ] Construct the tab content as a header containing Refresh Context, the Details view and a native action section. Enumerate only zero-parameter void `CallInEditor` functions, sort by Category/DisplayPriority/name, resolve the function again by name at click time, and invoke it under `FEditorScriptExecutionGuard`. When no eligible property/action exists, show a fixed empty-state text.
- [ ] Bind OnTabClosed to exactly-once Deinitialize, remove the session from the registry map and release the strong session reference.
- [ ] Write/green tests for invoke-existing focus with no duplicate instance, close/reopen fresh state and double-shutdown idempotence.
- [ ] Implement refresh: capture into a temporary result, keep old context on failure, otherwise assign session/extension CurrentContext, update Details and call BP_ContextRefreshed once.
- [ ] Re-run `Angelscript.Editor.ToolHost.Tabs`; expected all PASS.

## Task 4: Full Reload reconciliation and module lifecycle

**Files:**

- Extend registry implementation/tests.
- Modify `Source/AngelscriptEditor/Core/AngelscriptEditorModule.h/.cpp`.

**Interfaces:** `Initialize()` attaches one engine extension and registers after initial compile; `Shutdown()` removes all engine, command and tab state idempotently.

- [ ] Add tests for initial compile already finished, engine attached later, Full Reload and pre-exit ordering.
- [ ] On body-only reload, leave command/tab identities and live session in place.
- [ ] On Full Reload, compute the complete new declaration set before mutating registrations. Reconcile commands by stable ID; reconcile tabs by stable ID and compatible class.
- [ ] For compatible tab replacement, read the reflected session's fixed-up Extension pointer and call `DetailsView->SetObject` on it. Do not copy non-reflected fields manually.
- [ ] For removed/renamed/incompatible tab declarations, best-effort Deinitialize, close the tab and unregister the old spawner.
- [ ] Add `TUniquePtr<FAngelscriptEditorToolHostRegistry>` to the module, initialize after the existing Editor surfaces are available and shut it down before ToolMenus/global module teardown.
- [ ] Re-run commands, tabs, existing `Angelscript.Editor.MenuExtensions` and `Angelscript.Editor.Module.Menu` prefixes.

## Task 5: Inline AngelScript integration

**Files:**

- Create `Source/AngelscriptTest/Editor/AngelscriptEditorToolHostScriptTests.cpp`.

**Interfaces:** Consumes public Editor host types from the test module's existing Editor-only dependency.

- [ ] Create one inline AS command and one inline AS tab fixture with stable IDs and reflected callbacks:

  ```angelscript
  #if EDITOR
  class USelectionAuditCommand : UScriptEditorCommandExtension
  {
      default CommandName = n"SelectionAudit";
      default DisplayName = FText::FromString("Selection Audit");

      UFUNCTION(BlueprintOverride)
      void Execute(UAngelscriptEditorToolContext Context)
      {
          UEditorToolHostTestProbe::RecordActors(Context.SelectedActors.Num());
      }
  }

  class USelectionAuditTab : UScriptEditorTabExtension
  {
      default TabName = n"SelectionAudit";
      default DisplayName = FText::FromString("Selection Audit");

      UPROPERTY(EditAnywhere, Category="Audit")
      int Threshold = 10;

      UFUNCTION(CallInEditor, Category="Audit")
      void RunAudit()
      {
          UEditorToolHostTestProbe::RecordThreshold(Threshold);
      }
  }
  #endif
  ```

- [ ] Compile with a test-owned stable module, trigger registry reconciliation through a test seam, invoke command/tab and assert the AS callbacks saw the expected values.
- [ ] Perform a body-only update and a compatible reflected-property update; assert only the spec's physical/logical guarantees.
- [ ] Remove the fixture module and assert registrations/sessions are cleaned through reconciliation.
- [ ] Run:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Editor.ToolHost' -Label as-editor-tool-host-script -TimeoutMs 600000
  ```

  Expected: all integration methods PASS.

## Task 6: Documentation and final verification

**Files:**

- Modify `Documents/Knowledges/ZH/Guide_EditorExtension.md` first.
- Modify `Plugins/Angelscript/README.md` second.

- [ ] Document the explicit distinction: command object = per invocation, tab object = per open tab, subsystem/runner = user-chosen longer lifetime.
- [ ] Include one command and one tab example matching the checked public API; state that Details metadata controls presentation and arbitrary Slate is not supported.
- [ ] Explain stable IDs, shortcut preferences, duplicate rejection, explicit context refresh, stale snapshot validation and reload closure rules.
- [ ] Run final verification:

  ```powershell
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label as-editor-tool-host -TimeoutMs 1800000 -NoXGE
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.ToolHost' -Label as-editor-tool-host -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.TestModule.Editor.ToolHost' -Label as-editor-tool-host-script -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.MenuExtensions' -Label as-editor-menu-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix 'Angelscript.Editor.Module.Menu' -Label as-editor-module-menu-regression -TimeoutMs 600000
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-editor-tool-host-smoke -TimeoutMs 600000
  openspec validate feature-as-editor-tool-host-extensions --type change --strict --no-interactive
  ```

- [ ] Inspect parent and submodule diffs. Confirm no `Script/` file, Saved write, Runtime dependency, runner creation, filesystem scan, arbitrary Slate return or unrelated dirty-worktree edit entered the change.
- [ ] Record exact pass counts/report paths in `openspec/changes/feature-as-editor-tool-host-extensions/verification.md`; keep `tasks.md` as checkboxes only.

## Acceptance Gate

- A script command has a stable user-owned command identity and participates in normal keyboard shortcut configuration.
- Every command execution uses a fresh object and point-in-time context; no hidden command singleton exists.
- Every open script tab has one reflected session and Details-hosted object; close/reopen creates fresh state.
- Context capture never loads assets merely to describe selection, never auto-refreshes and never persists.
- Compatible reload preserves only existing reflected guarantees; incompatible declarations are closed/unregistered honestly.
- Existing menu extensions, Snippet behavior and Runtime dependencies remain unchanged.
