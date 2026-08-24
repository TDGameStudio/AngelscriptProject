// Theme: Feature.Inheritance. WorldStory BeginPlay override writes a UPROPERTY.
// C++: AngelscriptActorScriptOverrideTests.cpp::BeginPlayRunsInWorld
// Oracle after BeginPlay: BeginPlayObserved==1.
// Extra: empty handle null; pre-BeginPlay stays 0. FixtureIsolated. Keep BeginPlayObserved.

UCLASS()
class ATestScriptActorBeginPlayRunsInWorld : AActor
{
	UPROPERTY()
	int BeginPlayObserved = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayObserved = 1;
	}
}

bool Observe_BeginPlayRuns_EmptyHandleIsNull()
{
	ATestScriptActorBeginPlayRunsInWorld Actor;
	return Actor == nullptr;
}

int Observe_BeginPlayRuns_BeforeBeginPlay(ATestScriptActorBeginPlayRunsInWorld Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0168 setup: required ATestScriptActorBeginPlayRunsInWorld is null");
	}
	return Actor.BeginPlayObserved;
}

int Observe_BeginPlayRuns_AfterBeginPlay(ATestScriptActorBeginPlayRunsInWorld Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0168 setup: required ATestScriptActorBeginPlayRunsInWorld is null");
	}
	return Actor.BeginPlayObserved;
}
