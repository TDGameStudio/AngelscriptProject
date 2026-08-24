// Theme: Definitions.UClass. WorldStory UserConstructionScript then BeginPlay.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorConstructionScript
// Oracle: ConstructionScriptCalled>0 on spawn; BeginPlaySawConstruction=1.
// Extra: unset handle is null; pre-spawn counters stay 0. FixtureIsolated.

UCLASS()
class AConstructionActor : AActor
{
	UPROPERTY()
	int ConstructionScriptCalled = 0;

	UPROPERTY()
	int BeginPlaySawConstruction = 0;

	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionScriptCalled++;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (ConstructionScriptCalled > 0)
		{
			BeginPlaySawConstruction = 1;
		}
	}
}

bool Observe_ConstructionActor_EmptyDefaultIsNull()
{
	AConstructionActor Actor;
	return Actor == nullptr;
}

int Observe_ConstructionActor_CountersDefault(AConstructionActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0041 setup: required AConstructionActor is null");
	}
	return Actor.ConstructionScriptCalled + Actor.BeginPlaySawConstruction;
}
