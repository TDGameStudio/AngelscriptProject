// Theme: Feature.Inheritance. WorldStory Tick advances one logical count per world-time step.
// C++: AngelscriptActorScriptOverrideTests.cpp::TickRunsNTimes
// Oracle: FinalLogicalTickCount - InitialLogicalTickCount == DefaultActorTestTickCount (3).
// Extra: empty handle null; LastTickWorldTime default -1.0; Tick with no world keeps count 0.
// FixtureIsolated. Keep LogicalTickCount/LastTickWorldTime.

UCLASS()
class ATestScriptActorTickRunsNTimes : AActor
{
	UPROPERTY()
	int LogicalTickCount = 0;

	UPROPERTY()
	float LastTickWorldTime = -1.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().GetTimeSeconds();
		}

		if (CurrentTime > LastTickWorldTime)
		{
			LogicalTickCount += 1;
			LastTickWorldTime = CurrentTime;
		}
	}
}

bool Observe_TickRuns_EmptyHandleIsNull()
{
	ATestScriptActorTickRunsNTimes Actor;
	return Actor == nullptr;
}

int Observe_TickRuns_DefaultCount(ATestScriptActorTickRunsNTimes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0171 setup: required ATestScriptActorTickRunsNTimes is null");
	}
	return Actor.LogicalTickCount;
}

float Observe_TickRuns_DefaultLastWorldTime(ATestScriptActorTickRunsNTimes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0171 setup: required ATestScriptActorTickRunsNTimes is null");
	}
	return Actor.LastTickWorldTime;
}

int Observe_TickRuns_AfterWorldTicks(ATestScriptActorTickRunsNTimes Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0171 setup: required ATestScriptActorTickRunsNTimes is null");
	}
	return Actor.LogicalTickCount;
}
