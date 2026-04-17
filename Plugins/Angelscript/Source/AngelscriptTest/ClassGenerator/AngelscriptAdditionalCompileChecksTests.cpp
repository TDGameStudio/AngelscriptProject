#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_ClassGenerator_AngelscriptAdditionalCompileChecksTests_Private
{
	static const FName AdditionalChecksModuleName(TEXT("AdditionalChecksMod"));
	static const FString AdditionalChecksFilename(TEXT("AdditionalChecksMod.as"));
	static const FName AdditionalChecksClassName(TEXT("UAdditionalChecksTarget"));

	static const FName AdditionalChecksRejectedModuleName(TEXT("AdditionalChecksRejectMod"));
	static const FString AdditionalChecksRejectedFilename(TEXT("AdditionalChecksRejectMod.as"));
	static const FName AdditionalChecksRejectedClassName(TEXT("UAdditionalChecksRejectedTarget"));

	bool IsHandledReloadResult(const ECompileResult ReloadResult)
	{
		return ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled;
	}

	bool SummaryContainsDiagnosticMessage(const FAngelscriptCompileTraceSummary& Summary, const FString& ExpectedMessage)
	{
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Summary.Diagnostics)
		{
			if (Diagnostic.Message.Contains(ExpectedMessage))
			{
				return true;
			}
		}

		return false;
	}

	struct FTestAdditionalCompileChecks final : FAngelscriptAdditionalCompileChecks
	{
		int32 CompileCheckCount = 0;
		int32 PostReloadCount = 0;
		FString LastModuleName;
		FString LastClassName;
		bool bLastFullReload = false;
		bool bRejectCompile = false;
		FString RejectMessage = TEXT("Test additional compile check rejected the script class.");
		TArray<bool> PostReloadHistory;

		virtual bool ScriptCompileAdditionalChecks(TSharedPtr<FAngelscriptModuleDesc> ModuleDesc, TSharedPtr<FAngelscriptClassDesc> ClassDesc) override
		{
			++CompileCheckCount;
			LastModuleName = ModuleDesc.IsValid() ? ModuleDesc->ModuleName : FString();
			LastClassName = ClassDesc.IsValid() ? ClassDesc->ClassName : FString();

			if (bRejectCompile)
			{
				FAngelscriptEngine::Get().ScriptCompileError(ModuleDesc, 1, RejectMessage);
				return false;
			}

			return true;
		}

		virtual void PostReloadAdditionalChecks(bool bFullReload, TSharedPtr<FAngelscriptModuleDesc> ModuleDesc, TSharedPtr<FAngelscriptClassDesc> ClassDesc) override
		{
			++PostReloadCount;
			bLastFullReload = bFullReload;
			LastModuleName = ModuleDesc.IsValid() ? ModuleDesc->ModuleName : FString();
			LastClassName = ClassDesc.IsValid() ? ClassDesc->ClassName : FString();
			PostReloadHistory.Add(bFullReload);
		}
	};
}

using namespace AngelscriptTest_ClassGenerator_AngelscriptAdditionalCompileChecksTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAdditionalCompileChecksInvokeCompileAndPostReloadHooksTest,
	"Angelscript.TestModule.ClassGenerator.AdditionalCompileChecks.InvokeCompileAndPostReloadHooks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAdditionalCompileChecksInvokeCompileAndPostReloadHooksTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH

	TSharedPtr<FTestAdditionalCompileChecks> Recorder = MakeShared<FTestAdditionalCompileChecks>();
	Engine.AdditionalCompileChecks.Add(UObject::StaticClass(), StaticCastSharedPtr<FAngelscriptAdditionalCompileChecks>(Recorder));

	ON_SCOPE_EXIT
	{
		Engine.AdditionalCompileChecks.Remove(UObject::StaticClass());
		Engine.DiscardModule(*AdditionalChecksModuleName.ToString());
		Engine.DiscardModule(*AdditionalChecksRejectedModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
UCLASS()
class UAdditionalChecksTarget : UObject
{
	UPROPERTY()
	int Value = 1;
}
)AS");

	const FString ScriptV2 = TEXT(R"AS(
UCLASS()
class UAdditionalChecksTarget : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}
)AS");

	const FString RejectScript = TEXT(R"AS(
UCLASS()
class UAdditionalChecksRejectedTarget : UObject
{
	UPROPERTY()
	int Value = 3;
}
)AS");

	if (!TestTrue(
		TEXT("Initial additional-compile-checks module compile should succeed"),
		CompileAnnotatedModuleFromMemory(&Engine, AdditionalChecksModuleName, AdditionalChecksFilename, ScriptV1)))
	{
		return false;
	}

	UClass* InitialGeneratedClass = FindGeneratedClass(&Engine, AdditionalChecksClassName);
	if (!TestNotNull(TEXT("Initial additional-compile-checks compile should publish the generated script class"), InitialGeneratedClass))
	{
		return false;
	}

	TestEqual(TEXT("Initial annotated compile should invoke the compile hook exactly once"), Recorder->CompileCheckCount, 1);
	TestEqual(TEXT("Initial annotated compile should invoke the post-reload hook exactly once"), Recorder->PostReloadCount, 1);
	TestEqual(TEXT("Initial annotated compile should report the module name to the hook"), Recorder->LastModuleName, AdditionalChecksModuleName.ToString());
	TestEqual(TEXT("Initial annotated compile should report the generated class name to the hook"), Recorder->LastClassName, AdditionalChecksClassName.ToString());
	if (!TestEqual(TEXT("Initial annotated compile should record exactly one post-reload event"), Recorder->PostReloadHistory.Num(), 1))
	{
		return false;
	}
	TestTrue(TEXT("Initial annotated compile helper should surface the post-reload hook as a full reload"), Recorder->PostReloadHistory[0]);
	TestTrue(TEXT("Initial annotated compile helper should leave the last post-reload flag in full-reload state"), Recorder->bLastFullReload);

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(
		TEXT("Additional-compile-checks structural reload should compile successfully"),
		CompileModuleWithResult(&Engine, ECompileType::FullReload, AdditionalChecksModuleName, AdditionalChecksFilename, ScriptV2, ReloadResult)))
	{
		return false;
	}

	if (!TestTrue(
		TEXT("Additional-compile-checks structural reload should stay on a handled reload path"),
		IsHandledReloadResult(ReloadResult)))
	{
		return false;
	}

	UClass* ReloadedGeneratedClass = FindGeneratedClass(&Engine, AdditionalChecksClassName);
	if (!TestNotNull(TEXT("Additional-compile-checks full reload should keep the generated script class queryable"), ReloadedGeneratedClass))
	{
		return false;
	}

	TestNotEqual(TEXT("Additional-compile-checks full reload should replace the generated class object after a structural change"), ReloadedGeneratedClass, InitialGeneratedClass);
	TestEqual(TEXT("Full reload should invoke the compile hook for the replacement class"), Recorder->CompileCheckCount, 2);
	TestEqual(TEXT("Full reload should invoke the post-reload hook a second time"), Recorder->PostReloadCount, 2);
	if (!TestEqual(TEXT("Full reload should record two post-reload events in total"), Recorder->PostReloadHistory.Num(), 2))
	{
		return false;
	}
	TestTrue(TEXT("Full reload should report the second post-reload event as a full reload"), Recorder->PostReloadHistory[1]);
	TestTrue(TEXT("Full reload should leave the last post-reload flag in full-reload state"), Recorder->bLastFullReload);
	TestEqual(TEXT("Full reload should continue reporting the target module name"), Recorder->LastModuleName, AdditionalChecksModuleName.ToString());
	TestEqual(TEXT("Full reload should continue reporting the target class name"), Recorder->LastClassName, AdditionalChecksClassName.ToString());

	Recorder->bRejectCompile = true;

	FAngelscriptCompileTraceSummary RejectSummary;
	const bool bRejectedCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		AdditionalChecksRejectedModuleName,
		AdditionalChecksRejectedFilename,
		RejectScript,
		true,
		RejectSummary,
		true);

	TestFalse(TEXT("A rejecting additional compile check should fail compilation"), bRejectedCompiled);
	TestEqual(TEXT("A rejecting additional compile check should surface an error compile result"), RejectSummary.CompileResult, ECompileResult::Error);
	TestTrue(TEXT("A rejecting additional compile check should emit at least one diagnostic"), RejectSummary.Diagnostics.Num() > 0);
	TestTrue(TEXT("A rejecting additional compile check should preserve the rejection text in diagnostics"), SummaryContainsDiagnosticMessage(RejectSummary, Recorder->RejectMessage));
	TestEqual(TEXT("A rejecting additional compile check should still invoke the compile hook"), Recorder->CompileCheckCount, 3);
	TestEqual(TEXT("A rejecting additional compile check should not advance the post-reload hook count"), Recorder->PostReloadCount, 2);
	TestEqual(TEXT("A rejecting additional compile check should report the rejected module name"), Recorder->LastModuleName, AdditionalChecksRejectedModuleName.ToString());
	TestEqual(TEXT("A rejecting additional compile check should report the rejected class name"), Recorder->LastClassName, AdditionalChecksRejectedClassName.ToString());
	TestNull(TEXT("A rejecting additional compile check should not publish the rejected class"), FindGeneratedClass(&Engine, AdditionalChecksRejectedClassName));

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
