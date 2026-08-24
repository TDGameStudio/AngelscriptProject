// Theme: Definitions.UClass. WorldStory component BeginPlay/Tick/EndPlay on a DefaultComponent.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ComponentLifecycle
// Oracle: LifecycleComp.BeginPlayCalled=1; TickCount=1 AccumulatedDeltaTime=0.25; EndPlayCalled=1 after DestroyComponent.
// Extra: unset handles are null; pre-BeginPlay counters stay 0. FixtureIsolated.

UCLASS()
class ULifecycleComponent : UActorComponent
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCalled = 0;

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
}

UCLASS()
class AComponentOwnerActor : AActor
{
	UPROPERTY(DefaultComponent)
	ULifecycleComponent LifecycleComp;
}

bool Observe_ComponentOwner_EmptyDefaultIsNull()
{
	AComponentOwnerActor Actor;
	return Actor == nullptr;
}

bool Observe_LifecycleComponent_EmptyDefaultIsNull()
{
	ULifecycleComponent Comp;
	return Comp == nullptr;
}

int Observe_LifecycleComponent_CountersDefault(ULifecycleComponent Comp)
{
	if (Comp == nullptr)
	{
		throw("TS-DEF-0046 setup: required ULifecycleComponent is null");
	}
	return Comp.BeginPlayCalled + Comp.TickCount + Comp.EndPlayCalled;
}

int Observe_LifecycleComponent_TickZeroDeltaBoundary(ULifecycleComponent Comp)
{
	if (Comp == nullptr)
	{
		throw("TS-DEF-0046 setup: required ULifecycleComponent is null");
	}
	Comp.Tick(0.0f);
	return Comp.TickCount;
}
