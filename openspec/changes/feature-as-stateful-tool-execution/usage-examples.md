# Stateful Tool Usage Examples

> These examples describe the proposed API and are not runnable until this OpenSpec is implemented. They are documentation/test design material only; no example is added to the product `Script/` tree and the plugin does not discover or manage these tools.

## 1. User-authored stateful AngelScript tool

The tool is an ordinary user class. Its mutable fields belong to one Runner/Class/SessionKey logical session.

```angelscript
#if EDITOR

UCLASS()
class UMaterialAuditTool : UAngelscriptTool
{
    UPROPERTY()
    int RunCount = 0;

    UFUNCTION(BlueprintOverride)
    FAngelscriptToolResponse Run(const FAngelscriptToolInvocation& Invocation)
    {
        RunCount += 1;

        FAngelscriptToolResponse Response;
        Response.bSuccess = true;
        Response.Message = f"Material audit invocation {RunCount}";
        Response.PayloadJson = "{}";
        return Response;
    }
}

#endif
```

This is not a singleton. Two runners receive two different `UMaterialAuditTool` objects. One runner with two SessionKeys also receives two objects. Repeating the same class/key on one retained runner reuses its logical session.

## 2. User-owned Editor subsystem retains the runner

The user chooses an existing owner whose lifetime matches their workflow. The proposed runner is a reflected strong property, so normal UObject GC and Editor reinstancing can update it.

```angelscript
#if EDITOR

class UMyToolHost : UScriptEditorSubsystem
{
    UPROPERTY(Transient)
    UAngelscriptToolRunner ToolRunner;

    UFUNCTION(BlueprintOverride)
    void BP_Initialize()
    {
        ToolRunner = UAngelscriptToolLibrary::CreateRunner(this);
    }

    UFUNCTION(BlueprintOverride)
    void BP_Deinitialize()
    {
        if (ToolRunner != nullptr)
            ToolRunner.ResetAllSessions();
        ToolRunner = nullptr;
    }

    FAngelscriptToolRunResult RunMaterialAudit(UObject ExplicitContext)
    {
        FAngelscriptToolInvocation Invocation;
        Invocation.ContextObject = ExplicitContext;
        Invocation.ArgumentsJson = "{\"scope\":\"selected-assets\"}";

        return ToolRunner.RunTool(
            UMaterialAuditTool::StaticClass(),
            Invocation);
    }
}

#endif
```

Using the default SessionKey means repeated calls reuse `Default`. A real caller that needs parallel state sets a stable FName SessionKey. It should not generate a timestamp/GUID key for every click.

Runner reset means only “drop the retained session object.” It is not a deterministic cleanup callback for delegates, async work or external resources.

## 3. Temporary full-source compile and repeated runs

An Editor caller can keep one bounded scratch identity such as `Scratch/CurrentTool`. Compile-only never creates a Runner session.

```cpp
FAngelscriptEditorToolCompileRequest CompileRequest;
CompileRequest.SourceId = TEXT("Scratch/CurrentTool");
CompileRequest.ToolClassName = TEXT("UCurrentScratchTool");
CompileRequest.SourceText = FullAngelScriptSource;
CompileRequest.HistoryPolicy =
    EAngelscriptToolHistoryPolicy::SourceAndDiagnostics;

const FAngelscriptEditorToolCompileResult Compile =
    UAngelscriptEditorToolLibrary::CompileToolSource(CompileRequest);
```

The full source submitted above contains the same kind of AS class as example 1:

```angelscript
#if EDITOR

UCLASS()
class UCurrentScratchTool : UAngelscriptTool
{
    UPROPERTY()
    int Iteration = 0;

    UFUNCTION(BlueprintOverride)
    FAngelscriptToolResponse Run(const FAngelscriptToolInvocation& Invocation)
    {
        Iteration += 1;

        FAngelscriptToolResponse Response;
        Response.bSuccess = true;
        Response.Message = f"Scratch iteration {Iteration}";
        return Response;
    }
}

#endif
```

After compile success, the caller can run repeatedly without recompiling:

```cpp
FAngelscriptEditorToolRunRequest RunRequest;
RunRequest.Runner = RetainedRunner;
RunRequest.SourceId = TEXT("Scratch/CurrentTool");
RunRequest.ToolClassName = TEXT("UCurrentScratchTool");
RunRequest.Invocation.ContextObject = ExplicitContext;
RunRequest.HistoryPolicy =
    EAngelscriptToolHistoryPolicy::SourceDiagnosticsAndRunSummary;

const FAngelscriptEditorToolRunResult First =
    UAngelscriptEditorToolLibrary::RunCompiledTool(RunRequest);
const FAngelscriptEditorToolRunResult Second =
    UAngelscriptEditorToolLibrary::RunCompiledTool(RunRequest);
```

`First` and `Second` address the same Runner/Class/Default logical session. The second call observes `Iteration == 2`. A different retained Runner or SessionKey is isolated.

For one-click behavior, `CompileAndRunSource` composes the same two operations. It runs only when the submitted source succeeds; it never silently runs a previous last-known-good class after a failed update.

## 4. Failed update and explicit last-known-good run

Suppose `Scratch/CurrentTool` compiled successfully, then a later source submission has an error:

```cpp
const FAngelscriptEditorToolCompileResult Failed =
    UAngelscriptEditorToolLibrary::CompileToolSource(BrokenRequest);

if (Failed.Status == EAngelscriptEditorToolStatus::CompileFailed
    && Failed.bHasLastKnownGood)
{
    // Deliberate user choice: run the still-active exact module/class.
    const FAngelscriptEditorToolRunResult Previous =
        UAngelscriptEditorToolLibrary::RunCompiledTool(RunRequest);
}
```

The failing compile does not dispatch the broken source and does not reset the retained session. `ActiveRevisionId` may be empty when history was disabled or unavailable; live class validation, not the Saved record, decides whether running is possible.

## 5. Recover source after restarting the Editor

Recovery is data-only:

```cpp
const FAngelscriptToolHistorySourceListResult Recent =
    UAngelscriptEditorToolHistoryLibrary::ListRecentSources(20);

const FAngelscriptToolHistoryLoadResult Loaded =
    UAngelscriptEditorToolHistoryLibrary::LoadLastKnownGood(
        TEXT("Scratch/CurrentTool"));
```

`Loaded` returns SourceId, ToolClassName, RevisionId and exact SourceText. It does not compile, run or recreate the old UObject session. The user's UI/script must show or edit the source and then explicitly submit a new `CompileToolSource` request.

The store never persists:

- ContextObject or World identity;
- ArgumentsJson or PayloadJson;
- reflected/non-reflected fields from `UCurrentScratchTool`;
- prior side effects or a replay command.

## 6. Reset and forget are intentionally independent

```cpp
RetainedRunner->ResetSession(PreviousRun.RuntimeResult.SessionId);

UAngelscriptEditorToolHistoryLibrary::ForgetToolHistory(
    TEXT("Scratch/CurrentTool"));
```

- `ResetSession` drops one in-memory logical session; the next run creates a fresh UObject.
- `ForgetToolHistory` removes one Saved recovery subtree/index entry.
- Neither operation unloads the active memory module or generated UClass.
- Forgetting history does not reset a Runner; resetting a Runner does not delete history.

## 7. Runtime use without Editor source/history

A Debug, DebugGame or Development Runtime caller that already has a loaded tool class uses `UAngelscriptToolRunner::RunTool` directly. It does not link the Editor source/history API and causes no `Saved/Angelscript/ToolHistory` write.

Test and Shipping still contain the reflected Runtime types for compatibility, but `RunTool` returns `DisabledByBuild` before creating an instance.
