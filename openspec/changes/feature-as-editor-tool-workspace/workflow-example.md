# Tool Workspace Example Workflow

> This is a behavioral walkthrough of the proposed Editor UI, not a checked-in tool catalogue or an implementation screenshot.

## Start a temporary tool

1. Open **Window → AngelScript Tools → Tool Workspace**.
2. Choose **New Draft**.
3. Set SourceId to `Scratch/MaterialAudit`.
4. Set ToolClassName to `UMaterialAuditScratchTool`.
5. Edit the full-source template:

```angelscript
#if EDITOR

UCLASS()
class UMaterialAuditScratchTool : UAngelscriptTool
{
    UPROPERTY()
    int RunCount = 0;

    UFUNCTION(BlueprintOverride)
    FAngelscriptToolResponse Run(const FAngelscriptToolInvocation& Invocation)
    {
        RunCount += 1;

        UAngelscriptEditorToolContext Context =
            Cast<UAngelscriptEditorToolContext>(Invocation.ContextObject);

        FAngelscriptToolResponse Response;
        Response.bSuccess = Context != nullptr;
        Response.Message = Context != nullptr
            ? f"Run {RunCount}: {Context.SelectedAssets.Num()} captured assets"
            : "Editor context was not supplied";
        Response.PayloadJson = "{}";
        return Response;
    }
}

#endif
```

The initial draft autosaves only SourceId, ToolClassName, source, SessionKey and revision metadata. It does not persist invocation arguments, selected assets or `RunCount`.

## Compile once and run repeatedly

- **Compile** publishes the stable `/Angelscript/Memory/Tools/Scratch/MaterialAudit.as` source and returns diagnostics without creating a tool object.
- **Run Active** captures the editor selection at click time and runs the active class through the workspace-owned runner.
- Repeated **Run Active** calls reuse the same runner/class/SessionKey logical session, so `RunCount` becomes 2, 3 and so on without recompilation.
- **Reset Session** removes that exact in-memory session. The next run creates a fresh object with `RunCount == 1`; source history and the draft remain.

## Recover from a failed edit

Suppose the next edit does not compile:

- The source editor keeps the failed text.
- Diagnostics navigate to its row and column.
- **Compile & Run** does not run anything after the failure.
- If the old active class remains valid, the UI shows a distinct **Run Last Known Good** action.
- Choosing that action runs the old active code deliberately; it does not replace the failed buffer with old source.

To restore source, open **Recovery/History**, select an exact retained revision and choose **Load Into Buffer**. Loading is data-only. The restored text remains unsubmitted until Compile or Compile & Run is pressed.

## Export when the scratch tool becomes useful

Choose **Export Current Buffer As...** or select an exact history revision and choose **Export Revision As...**. The save dialog chooses the destination; the plugin does not require or create `Script/Tools`.

After export:

- the `.as` file belongs to the user/project;
- the workspace does not register it in a catalogue;
- the draft and Tool History remain until the user forgets them separately;
- if the destination is already inside a watched script root, the normal directory watcher may compile it through ordinary Hot Reload.

## Three independent kinds of state

```text
Workspace Draft
  Saved/Angelscript/ToolWorkspace/v1
  Unsubmitted source recovery only

Tool History
  Saved/Angelscript/ToolHistory/v1
  Submitted source revisions + compile attempts + optional minimized run summaries

Runner Session
  Memory only
  Mutable UAngelscriptTool fields for the current Editor process
```

Deleting or resetting one does not implicitly modify the other two.
