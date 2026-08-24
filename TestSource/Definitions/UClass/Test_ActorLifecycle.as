// Theme: Definitions.UClass. WorldStory actor BeginPlay/Tick/EndPlay/Destroyed overrides.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorLifecycle
// Oracle after spawn+BeginPlay: BeginPlayCalled=1. Extra: unset handle is null;
// pre-BeginPlay counters stay 0. FixtureIsolated.

UCLASS()
class ALifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCalled = 0;

	UPROPERTY()
	int DestroyedCalled = 0;

	UPROPERTY()
	float AccumulatedDeltaTime = 0.0f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaSeconds)
	{
		TickCount++;
		AccumulatedDeltaTime += DeltaSeconds;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCalled = 1;
	}
}

bool Observe_LifecycleActor_EmptyDefaultIsNull()
{
	ALifecycleActor Actor;
	return Actor == nullptr;
}

int Observe_LifecycleActor_CountersBeforeBeginPlay(ALifecycleActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0040 setup: required ALifecycleActor is null");
	}
	return Actor.BeginPlayCalled + Actor.TickCount + Actor.EndPlayCalled + Actor.DestroyedCalled;
}

int Observe_LifecycleActor_TickZeroDeltaBoundary(ALifecycleActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0040 setup: required ALifecycleActor is null");
	}
	Actor.Tick(0.0f);
	return Actor.TickCount;
}
