#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/CoreNetTypes.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelinePropertyReplicationConditionTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.PropertyReplicationConditionRoundTrip"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/PropertyReplicationConditionRoundTrip.as"));
	static const FString ClassName(TEXT("APropertyReplicationConditionCarrier"));
	static const FString OwnerOnlyPropertyName(TEXT("OwnerOnlyValue"));
	static const FString SkipReplayPropertyName(TEXT("SkipReplayValue"));
	static const FString EntryFunctionDeclaration(TEXT("int Entry()"));
	static const int32 ExpectedEntryValue = 42;

	FString JoinDiagnostics(const TArray<FAngelscriptCompileTraceDiagnosticSummary>& Diagnostics)
	{
		TArray<FString> Lines;
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Diagnostics)
		{
			Lines.Add(FString::Printf(
				TEXT("[%s] %s(%d:%d) %s"),
				Diagnostic.bIsError ? TEXT("Error") : (Diagnostic.bIsInfo ? TEXT("Info") : TEXT("Warning")),
				*Diagnostic.Section,
				Diagnostic.Row,
				Diagnostic.Column,
				*Diagnostic.Message));
		}

		return FString::Join(Lines, TEXT(" | "));
	}
}

using namespace CompilerPipelinePropertyReplicationConditionTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerPropertyReplicationConditionRoundTripTest,
	"Angelscript.TestModule.Compiler.EndToEnd.PropertyReplicationConditionRoundTrip",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerPropertyReplicationConditionRoundTripTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS()
class APropertyReplicationConditionCarrier : AActor
{
	UPROPERTY(Replicated, ReplicationCondition=OwnerOnly)
	int OwnerOnlyValue = 11;

	UPROPERTY(Replicated, ReplicationCondition=SkipReplay)
	int SkipReplayValue = 31;
}

int Entry()
{
	return 42;
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelinePropertyReplicationConditionTest::ModuleName.ToString());
	};

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelinePropertyReplicationConditionTest::ModuleName,
		CompilerPipelinePropertyReplicationConditionTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	if (Summary.Diagnostics.Num() > 0)
	{
		AddInfo(FString::Printf(
			TEXT("Compile diagnostics: %s"),
			*CompilerPipelinePropertyReplicationConditionTest::JoinDiagnostics(Summary.Diagnostics)));
	}

	bPassed &= TestTrue(
		TEXT("Property replication-condition round-trip should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Property replication-condition round-trip should record preprocessor usage in the compile summary"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Property replication-condition round-trip should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	bPassed &= TestEqual(
		TEXT("Property replication-condition round-trip should stay on the full-reload handled path"),
		Summary.CompileResult,
		ECompileResult::FullyHandled);
	bPassed &= TestEqual(
		TEXT("Property replication-condition round-trip should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled || !Summary.bCompileSucceeded)
	{
		return false;
	}

	int32 EntryResult = 0;
	const bool bExecuted = ExecuteIntFunction(
		&Engine,
		CompilerPipelinePropertyReplicationConditionTest::RelativeScriptPath,
		CompilerPipelinePropertyReplicationConditionTest::ModuleName,
		CompilerPipelinePropertyReplicationConditionTest::EntryFunctionDeclaration,
		EntryResult);
	bPassed &= TestTrue(
		TEXT("Property replication-condition round-trip should execute the compiled entry function"),
		bExecuted);
	if (bExecuted)
	{
		bPassed &= TestEqual(
			TEXT("Property replication-condition round-trip should preserve module execution after metadata propagation"),
			EntryResult,
			CompilerPipelinePropertyReplicationConditionTest::ExpectedEntryValue);
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelinePropertyReplicationConditionTest::ClassName);
	if (!TestNotNull(TEXT("Property replication-condition round-trip should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	FIntProperty* OwnerOnlyProperty = FindFProperty<FIntProperty>(GeneratedClass, *CompilerPipelinePropertyReplicationConditionTest::OwnerOnlyPropertyName);
	FIntProperty* SkipReplayProperty = FindFProperty<FIntProperty>(GeneratedClass, *CompilerPipelinePropertyReplicationConditionTest::SkipReplayPropertyName);
	if (!TestNotNull(TEXT("Property replication-condition round-trip should materialize the OwnerOnly property"), OwnerOnlyProperty)
		|| !TestNotNull(TEXT("Property replication-condition round-trip should materialize the SkipReplay property"), SkipReplayProperty))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("OwnerOnly property should carry CPF_Net"),
		OwnerOnlyProperty->HasAnyPropertyFlags(CPF_Net));
	bPassed &= TestTrue(
		TEXT("SkipReplay property should carry CPF_Net"),
		SkipReplayProperty->HasAnyPropertyFlags(CPF_Net));
	bPassed &= TestEqual(
		TEXT("OwnerOnly property should preserve COND_OwnerOnly"),
		OwnerOnlyProperty->GetBlueprintReplicationCondition(),
		COND_OwnerOnly);
	bPassed &= TestEqual(
		TEXT("SkipReplay property should preserve COND_SkipReplay"),
		SkipReplayProperty->GetBlueprintReplicationCondition(),
		COND_SkipReplay);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
