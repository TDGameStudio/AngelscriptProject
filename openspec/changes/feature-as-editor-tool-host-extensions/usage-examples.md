# Editor Tool Host Usage Examples

> These examples describe the proposed API. They are design/test material until the OpenSpec is implemented. They remain user-authored source examples and are not added to the product `Script/` tree or discovered as `UAngelscriptTool` entries.

## 1. Selection-aware keyboard command

One concrete class declares one stable command. The command object is new for each invocation, so persistent counters belong elsewhere.

```angelscript
#if EDITOR

class UPrintSelectedActorsCommand : UScriptEditorCommandExtension
{
    default CommandName = n"Project.PrintSelectedActors";
    default DisplayName = FText::FromString("Print Selected Actors");
    default Description = FText::FromString(
        "Prints the actor selection captured when the command executes.");
    default IconName = n"Icons.Search";

    UFUNCTION(BlueprintOverride)
    bool CanExecute() const
    {
        // Keep this fast: CanExecute runs on the class default object and does
        // not capture the current selection.
        return GEditor != nullptr;
    }

    UFUNCTION(BlueprintOverride)
    void Execute(UAngelscriptEditorToolContext Context)
    {
        if (Context == nullptr)
            return;

        Print(f"Captured actors: {Context.SelectedActors.Num()}");
        for (AActor Actor : Context.SelectedActors)
        {
            if (IsValid(Actor))
                Print(Actor.GetPathName());
        }
    }
}

#endif
```

`Project.PrintSelectedActors` is the durable command identity. The user assigns or overrides its shortcut in Unreal Editor Keyboard Shortcuts under the AngelScript Tools context. Renaming the class does not change that command ID; changing CommandName does.

## 2. Fixed tool tab generated from reflected properties

The tab host creates one object while the physical tab is open and uses a normal Details view for its UI.

```angelscript
#if EDITOR

class UMaterialAuditTab : UScriptEditorTabExtension
{
    default TabName = n"Project.MaterialAudit";
    default DisplayName = FText::FromString("Material Audit");
    default ToolTip = FText::FromString(
        "Audits assets from an explicitly refreshed editor context.");

    UPROPERTY(EditAnywhere, Category = "Audit")
    bool bIncludeInstances = true;

    UPROPERTY(EditAnywhere, Category = "Audit", Meta = (ClampMin = "1", ClampMax = "10000"))
    int MaxAssets = 500;

    UPROPERTY(VisibleAnywhere, Category = "Result")
    int LastAuditedCount = 0;

    UFUNCTION(BlueprintOverride)
    void BP_Initialize(UAngelscriptEditorToolContext Context)
    {
        Print("Material Audit tab opened");
    }

    UFUNCTION(BlueprintOverride)
    void BP_ContextRefreshed(UAngelscriptEditorToolContext Context)
    {
        Print(f"Context refreshed: {Context.SelectedAssets.Num()} assets");
    }

    UFUNCTION(CallInEditor, Category = "Audit")
    void AuditCapturedAssets()
    {
        UAngelscriptEditorToolContext Context = CurrentContext;
        if (Context == nullptr)
            return;

        LastAuditedCount = Math::Min(Context.SelectedAssets.Num(), MaxAssets);
        Print(f"Would audit {LastAuditedCount} assets");
    }

    UFUNCTION(BlueprintOverride)
    void BP_Deinitialize()
    {
        Print("Material Audit tab closed");
    }
}

#endif
```

Changing the Content Browser selection does not silently change `CurrentContext`. The user presses the native **Refresh Context** control, which replaces the snapshot and invokes `BP_ContextRefreshed`.

Closing and reopening the tab resets `LastAuditedCount` to the class default. A compatible Hot Reload may preserve reflected fields while the same tab remains open, but incompatible class/TabName changes close the tab instead of pretending migration succeeded.

## 3. Durable user-owned state lives in a subsystem

When a command and a tab must share state, the user owns that state explicitly:

```angelscript
#if EDITOR

class UProjectToolState : UScriptEditorSubsystem
{
    UPROPERTY(Transient)
    UAngelscriptToolRunner Runner;

    UPROPERTY(Transient)
    int AuditRunCount = 0;

    UFUNCTION(BlueprintOverride)
    void BP_Initialize()
    {
        Runner = UAngelscriptToolLibrary::CreateRunner(this);
    }

    UFUNCTION(BlueprintOverride)
    void BP_Deinitialize()
    {
        if (Runner != nullptr)
            Runner.ResetAllSessions();
        Runner = nullptr;
    }
}

#endif
```

The command or tab resolves `UProjectToolState` through the existing Editor subsystem library, increments its own user-defined counters and chooses which loaded `UAngelscriptTool` class to run. The host extension does not discover that class or retain the runner.

## 4. Lifetime summary

| Object | Owner | Default lifetime | Persists after restart |
|---|---|---|---|
| Command instance | Command host invocation | One synchronous Execute callback | No |
| Command context | Command instance | One synchronous Execute callback unless user retains it | No |
| Tab extension instance | Reflected tab session | One physical open tab | No |
| Tab context | Reflected tab session | Until explicit refresh or tab close | No |
| User Editor subsystem | Unreal Editor subsystem collection | Current Editor process | Only user-configured data, not UObject instance |
| User tool runner | Explicit user Owner | While the Owner retains it | No |
