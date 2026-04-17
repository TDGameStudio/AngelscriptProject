#include "../../Shared/AngelscriptLearningTrace.h"
#include "../../Shared/AngelscriptTestEngineHelper.h"
#include "../../Shared/AngelscriptTestUtilities.h"
#include "../../Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/AngelscriptClassGenerator.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Learning_Runtime_AngelscriptLearningReloadAndClassAnalysisTests_Private
{
	struct FLearningReloadScenario
	{
		FString ScenarioLabel;
		FName ModuleName;
		FString Filename;
		FString BaselineScript;
		FString UpdatedScript;
		FString ChangeSummary;
		FAngelscriptClassGenerator::EReloadRequirement ExpectedRequirement = FAngelscriptClassGenerator::Error;
		bool bExpectedWantsFullReload = false;
		bool bExpectedNeedsFullReload = false;
	};

	struct FLearningReloadOutcome
	{
		bool bBaselineCompiled = false;
		bool bAnalyzed = false;
		FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
		bool bWantsFullReload = false;
		bool bNeedsFullReload = false;
	};

	FString GetReloadRequirementLabel(FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement)
	{
		switch (ReloadRequirement)
		{
		case FAngelscriptClassGenerator::SoftReload:
			return TEXT("SoftReload");
		case FAngelscriptClassGenerator::FullReloadSuggested:
			return TEXT("FullReloadSuggested");
		case FAngelscriptClassGenerator::FullReloadRequired:
			return TEXT("FullReloadRequired");
		case FAngelscriptClassGenerator::Error:
		default:
			return TEXT("Error");
		}
	}

	FLearningReloadOutcome RunReloadScenario(FAngelscriptEngine& Engine, const FLearningReloadScenario& Scenario)
	{
		FLearningReloadOutcome Outcome;
		ResetSharedCloneEngine(Engine);
		Outcome.bBaselineCompiled = CompileAnnotatedModuleFromMemory(&Engine, Scenario.ModuleName, Scenario.Filename, Scenario.BaselineScript);
		if (!Outcome.bBaselineCompiled)
		{
			return Outcome;
		}

		Outcome.bAnalyzed = AnalyzeReloadFromMemory(
			&Engine,
			Scenario.ModuleName,
			Scenario.Filename,
			Scenario.UpdatedScript,
			Outcome.ReloadRequirement,
			Outcome.bWantsFullReload,
			Outcome.bNeedsFullReload);
		return Outcome;
	}

	void TraceReloadScenario(FAngelscriptLearningTraceSession& Trace, const FLearningReloadScenario& Scenario, const FLearningReloadOutcome& Outcome)
	{
		Trace.AddStep(Scenario.ScenarioLabel, Outcome.bAnalyzed ? TEXT("Reload analysis completed for the updated script version") : TEXT("Reload analysis stopped before producing a stable decision"));
		Trace.AddKeyValue(TEXT("ModuleName"), Scenario.ModuleName.ToString());
		Trace.AddKeyValue(TEXT("Filename"), Scenario.Filename);
		Trace.AddKeyValue(TEXT("ChangeSummary"), Scenario.ChangeSummary);
		Trace.AddKeyValue(TEXT("BaselineCompiled"), Outcome.bBaselineCompiled ? TEXT("true") : TEXT("false"));
		Trace.AddKeyValue(TEXT("ReloadRequirement"), GetReloadRequirementLabel(Outcome.ReloadRequirement));
		Trace.AddKeyValue(TEXT("WantsFullReload"), Outcome.bWantsFullReload ? TEXT("true") : TEXT("false"));
		Trace.AddKeyValue(TEXT("NeedsFullReload"), Outcome.bNeedsFullReload ? TEXT("true") : TEXT("false"));
	}
}

using namespace AngelscriptTest_Learning_Runtime_AngelscriptLearningReloadAndClassAnalysisTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptLearningReloadAndClassAnalysisTest,
	"Angelscript.TestModule.Learning.Runtime.ReloadAnalysis",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptLearningReloadAndClassAnalysisTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	ResetSharedCloneEngine(Engine);
	ON_SCOPE_EXIT
	{
		ResetSharedCloneEngine(Engine);
	};

	FAngelscriptLearningTraceSinkConfig SinkConfig;
	SinkConfig.bEmitToAutomation = true;
	SinkConfig.bEmitToLog = true;
	SinkConfig.bEmitToFile = false;

	FAngelscriptLearningTraceSession Trace(TEXT("LearningReloadAnalysis"), SinkConfig);
	Trace.BeginPhase(EAngelscriptLearningTracePhase::Compile);

	const FLearningReloadScenario BodyOnlyScenario{
		TEXT("AnalyzeReload.BodyOnlyChange"),
		TEXT("LearningReloadBodyOnlyModule"),
		TEXT("LearningReloadBodyOnlyModule.as"),
		TEXT(R"AS(
UCLASS()
class ULearningReloadBodyOnlyTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}
)AS"),
		TEXT(R"AS(
UCLASS()
class ULearningReloadBodyOnlyTarget : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
)AS"),
		TEXT("Only the function body changed; class layout and signatures stayed the same."),
		FAngelscriptClassGenerator::SoftReload,
		false,
		false,
	};
	const FLearningReloadOutcome BodyOnlyOutcome = RunReloadScenario(Engine, BodyOnlyScenario);
	TraceReloadScenario(Trace, BodyOnlyScenario, BodyOnlyOutcome);

	const FLearningReloadScenario ClassAddedScenario{
		TEXT("AnalyzeReload.ClassAdded"),
		TEXT("LearningReloadClassAddedModule"),
		TEXT("LearningReloadClassAddedModule.as"),
		TEXT(R"AS(
UCLASS()
class UExistingLearningReloadTarget : UObject
{
}
)AS"),
		TEXT(R"AS(
UCLASS()
class UExistingLearningReloadTarget : UObject
{
}

UCLASS()
class UNewLearningReloadTarget : UObject
{
}
)AS"),
		TEXT("A second script class was added to the module, changing the generated-type set."),
		FAngelscriptClassGenerator::FullReloadSuggested,
		true,
		false,
	};
	const FLearningReloadOutcome ClassAddedOutcome = RunReloadScenario(Engine, ClassAddedScenario);
	TraceReloadScenario(Trace, ClassAddedScenario, ClassAddedOutcome);

	const FLearningReloadScenario SignatureChangeScenario{
		TEXT("AnalyzeReload.FunctionSignatureChanged"),
		TEXT("LearningReloadSignatureModule"),
		TEXT("LearningReloadSignatureModule.as"),
		TEXT(R"AS(
UCLASS()
class ULearningReloadSignatureTarget : UObject
{
	UFUNCTION()
	int ComputeValue()
	{
		return 1;
	}
}
)AS"),
		TEXT(R"AS(
UCLASS()
class ULearningReloadSignatureTarget : UObject
{
	UFUNCTION()
	float ComputeValue(float Scale)
	{
		return Scale;
	}
}
)AS"),
		TEXT("The UFUNCTION signature changed from int ComputeValue() to float ComputeValue(float)."),
		FAngelscriptClassGenerator::FullReloadRequired,
		true,
		true,
	};
	const FLearningReloadOutcome SignatureChangeOutcome = RunReloadScenario(Engine, SignatureChangeScenario);
	TraceReloadScenario(Trace, SignatureChangeScenario, SignatureChangeOutcome);

	const bool bBodyOnlyBaselineCompiled = TestTrue(TEXT("Body-only baseline module should compile"), BodyOnlyOutcome.bBaselineCompiled);
	const bool bBodyOnlyAnalyzed = TestTrue(TEXT("Body-only change should analyze successfully"), BodyOnlyOutcome.bAnalyzed);
	const bool bBodyOnlyRequirement = TestEqual(TEXT("Body-only change should remain soft reload"), BodyOnlyOutcome.ReloadRequirement, BodyOnlyScenario.ExpectedRequirement);
	const bool bBodyOnlyFlags = TestFalse(TEXT("Body-only change should not request full reload"), BodyOnlyOutcome.bWantsFullReload || BodyOnlyOutcome.bNeedsFullReload);

	const bool bClassAddedBaselineCompiled = TestTrue(TEXT("Class-added baseline module should compile"), ClassAddedOutcome.bBaselineCompiled);
	const bool bClassAddedAnalyzed = TestTrue(TEXT("Class-added change should analyze successfully"), ClassAddedOutcome.bAnalyzed);
	const bool bClassAddedRequirement = TestEqual(TEXT("Class-added change should suggest a full reload"), ClassAddedOutcome.ReloadRequirement, ClassAddedScenario.ExpectedRequirement);
	const bool bClassAddedFlags = TestTrue(TEXT("Class-added change should request the full reload path"), ClassAddedOutcome.bWantsFullReload && !ClassAddedOutcome.bNeedsFullReload);

	const bool bSignatureBaselineCompiled = TestTrue(TEXT("Signature-change baseline module should compile"), SignatureChangeOutcome.bBaselineCompiled);
	const bool bSignatureAnalyzed = TestTrue(TEXT("Signature change should analyze successfully"), SignatureChangeOutcome.bAnalyzed);
	const bool bSignatureRequirement = TestEqual(TEXT("Signature change should require a full reload"), SignatureChangeOutcome.ReloadRequirement, SignatureChangeScenario.ExpectedRequirement);
	const bool bSignatureFlags = TestTrue(TEXT("Signature change should mark full reload as required"), SignatureChangeOutcome.bWantsFullReload && SignatureChangeOutcome.bNeedsFullReload);

	const bool bPhaseSequenceOk = AssertLearningTracePhaseSequence(*this, Trace.GetEvents(), {
		EAngelscriptLearningTracePhase::Compile,
	});
	const bool bContainsSoftReloadKeyword = AssertLearningTraceContainsKeyword(*this, Trace.GetEvents(), TEXT("SoftReload"));
	const bool bContainsFullReloadRequiredKeyword = AssertLearningTraceContainsKeyword(*this, Trace.GetEvents(), TEXT("FullReloadRequired"));
	const bool bMinimumEventsOk = AssertLearningTraceMinimumEventCount(*this, Trace.GetEvents(), 3);

	Trace.FlushToAutomation(*this);
	Trace.FlushToLog();
	return bBodyOnlyBaselineCompiled
		&& bBodyOnlyAnalyzed
		&& bBodyOnlyRequirement
		&& bBodyOnlyFlags
		&& bClassAddedBaselineCompiled
		&& bClassAddedAnalyzed
		&& bClassAddedRequirement
		&& bClassAddedFlags
		&& bSignatureBaselineCompiled
		&& bSignatureAnalyzed
		&& bSignatureRequirement
		&& bSignatureFlags
		&& bPhaseSequenceOk
		&& bContainsSoftReloadKeyword
		&& bContainsFullReloadRequiredKeyword
		&& bMinimumEventsOk;

	ASTEST_END_SHARE
}

#endif
