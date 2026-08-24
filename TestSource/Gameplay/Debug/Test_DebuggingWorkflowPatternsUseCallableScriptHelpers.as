// Theme: Gameplay.Debug. WorldStory callable workflow helpers (log + probe state).
// C++: AngelscriptCoverageDebugTests.cpp::DebuggingWorkflowPatternsUseCallableScriptHelpers
// Oracle: TraceBranch(4)==1; TraceBranch(42)==2; RecordReproContext==1;
// ProbeCount 2; bConditionalProbeHit true; LastProbe "High:42".
// Extra: defaults ProbeCount 0 / empty LastProbe / false flags; empty StepName returns 0.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ADebugWorkflowCoverageActor : AActor
{
	UPROPERTY()
	int ProbeCount = 0;

	UPROPERTY()
	FString LastProbe = "";

	UPROPERTY()
	bool bRecordedReproContext = false;

	UPROPERTY()
	bool bConditionalProbeHit = false;

	UFUNCTION()
	int TraceBranch(int Value)
	{
		Log(n"CoverageDebugWorkflow", "Enter TraceBranch Value=" + Value);

		if (Value > 10)
		{
			ProbeCount++;
			LastProbe = "High:" + Value;
			bConditionalProbeHit = true;
			Log(n"CoverageDebugWorkflow", "Branch High Value=" + Value);
		}
		else
		{
			ProbeCount++;
			LastProbe = "Low:" + Value;
			Log(n"CoverageDebugWorkflow", "Branch Low Value=" + Value);
		}

		Log(n"CoverageDebugWorkflow", "Exit TraceBranch ProbeCount=" + ProbeCount);
		return ProbeCount;
	}

	UFUNCTION()
	int RecordReproContext(FString StepName)
	{
		Log(n"CoverageDebugWorkflow", "ReproStep=" + StepName + " Actor=" + GetName() + " Class=" + GetClass().GetName());
		bRecordedReproContext = StepName.Len() > 0 && GetName().ToString().Len() > 0;
		return bRecordedReproContext ? 1 : 0;
	}
}

bool Observe_Workflow_DefaultEmpty(ADebugWorkflowCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DebuggingWorkflowPatternsUseCallableScriptHelpers setup: required Actor is null");
	}
	return Actor.ProbeCount == 0
		&& Actor.LastProbe.Len() == 0
		&& Actor.bRecordedReproContext == false
		&& Actor.bConditionalProbeHit == false;
}

bool Observe_Workflow_Nominal(ADebugWorkflowCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DebuggingWorkflowPatternsUseCallableScriptHelpers setup: required Actor is null");
	}
	int Low = Actor.TraceBranch(4);
	int High = Actor.TraceBranch(42);
	return Low == 1
		&& High == 2
		&& Actor.ProbeCount == 2
		&& Actor.bConditionalProbeHit == true
		&& Actor.LastProbe == "High:42";
}

bool Observe_Workflow_EmptyStepName(ADebugWorkflowCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DebuggingWorkflowPatternsUseCallableScriptHelpers setup: required Actor is null");
	}
	return Actor.RecordReproContext("") == 0 && Actor.bRecordedReproContext == false;
}
