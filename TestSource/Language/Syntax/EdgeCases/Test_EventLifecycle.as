// Theme: Language.Syntax.EdgeCases. WorldStory actor lifecycle plus custom event.
// C++: AngelscriptCoverageEventTests.cpp::EventLifecycle
// sha256=1803d4ef891d175abd4410ab6e5d6e8f0993da5e719cce2e1d23cf79df154cd0; lines 331-379.
// Oracle: BeginPlayCount=1; TickCount>=1 after world ticks; EndPlayCount=1 on Destroy;
// LifecycleEventCount=2 (Broadcast from BeginPlay and EndPlay).
// Extra: local construct leaves all counts at 0. FixtureIsolated.

event void FCoverageLifecycleEvent();

UCLASS()
class ACoverageEventLifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int LifecycleEventCount = 0;

	UPROPERTY()
	FCoverageLifecycleEvent OnLifecycle;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnLifecycle.AddUFunction(this, n"HandleLifecycle");
		BeginPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	UFUNCTION()
	void HandleLifecycle()
	{
		LifecycleEventCount += 1;
	}
}

bool Observe_EventLifecycle_DefaultEmpty(ACoverageEventLifecycleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventLifecycle setup: required Actor is null");
	}
	return Actor.BeginPlayCount == 0 && Actor.TickCount == 0 && Actor.EndPlayCount == 0 && Actor.LifecycleEventCount == 0;
}
