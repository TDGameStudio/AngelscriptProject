// Theme: World.Component. WorldStory: DestroyProbeComponent EndPlay count
// and IsBeingDestroyed.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentDestructionCallbacksAndState
// sha256=fef10142009ca9c9d617641426096f6547913be690ce182da41318df78413abe; lines 2876-2919.
// Oracle: DestroyCallCompleted true, BeingDestroyedAfterCall true,
// EndPlayCount=1. Extra: local construct flags false, EndPlayCount 0,
// DestroyProbe null. FixtureIsolated.

UCLASS()
class UCoverageDestroyStateComponent : UActorComponent
{
	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	bool DestroyingDuringEndPlay = false;

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount++;
		DestroyingDuringEndPlay = IsBeingDestroyed();
	}
}

UCLASS()
class ACoverageComponentDestructionStateActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDestroyStateComponent DestroyProbe;

	UPROPERTY()
	bool DestroyCallCompleted = false;

	UPROPERTY()
	bool BeingDestroyedAfterCall = false;

	UFUNCTION()
	void DestroyProbeComponent()
	{
		if (DestroyProbe == nullptr)
		{
			return;
		}

		DestroyProbe.DestroyComponent();
		DestroyCallCompleted = true;
		BeingDestroyedAfterCall = DestroyProbe.IsBeingDestroyed();
	}
}

bool Observe_DestructionCallbacks_DefaultEmpty(ACoverageComponentDestructionStateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentDestructionCallbacksAndState setup: required Actor is null");
	}
	return !Actor.DestroyCallCompleted
		&& !Actor.BeingDestroyedAfterCall
		&& Actor.DestroyProbe == nullptr;
}

bool Observe_DestructionCallbacks_NullProbeIsNoop(ACoverageComponentDestructionStateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentDestructionCallbacksAndState setup: required Actor is null");
	}
	Actor.DestroyProbeComponent();
	return !Actor.DestroyCallCompleted && !Actor.BeingDestroyedAfterCall;
}
