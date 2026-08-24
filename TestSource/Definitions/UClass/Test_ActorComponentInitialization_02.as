// Theme: Definitions.UClass. WorldStory DefaultComponent available at BeginPlay.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::ActorComponentInitialization
// Oracle: BeginPlayCalled=1; RootComponentAvailableAtBeginPlay=1; RootComp owned and registered.
// Extra: unset handle is null; pre-BeginPlay counters stay 0. FixtureIsolated.

UCLASS()
class AComponentInitActor : AActor
{
	UPROPERTY()
	int BeginPlayCalled = 0;

	UPROPERTY()
	int RootComponentAvailableAtBeginPlay = 0;

	UPROPERTY(DefaultComponent)
	USceneComponent RootComp;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
		if (RootComp != nullptr)
		{
			RootComponentAvailableAtBeginPlay = 1;
		}
	}
}

bool Observe_ComponentInitActor_EmptyDefaultIsNull()
{
	AComponentInitActor Actor;
	return Actor == nullptr;
}

int Observe_ComponentInitActor_CountersDefault(AComponentInitActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0050 setup: required AComponentInitActor is null");
	}
	return Actor.BeginPlayCalled + Actor.RootComponentAvailableAtBeginPlay;
}
