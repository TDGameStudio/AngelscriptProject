// Theme: World.Component. WorldStory: DestroyComponent from Tick.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentDestruction
// sha256=5f1252444e519a8b56e931d356d9418e48c1ca8b920b1ff0ffd72f6339ce992d; lines 2687-2712.
// Oracle VerifyByPath WasDestroyed=true after Tick. Extra: local construct
// WasDestroyed false, TestComp null. FixtureIsolated.

UCLASS()
class UCoverageDestructionComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentDestructionActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageDestructionComponent TestComp;

	UPROPERTY()
	bool WasDestroyed = false;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp != nullptr && !TestComp.IsBeingDestroyed())
		{
			TestComp.DestroyComponent();
			WasDestroyed = true;
		}
	}
}

bool Observe_ComponentDestruction_DefaultFalse(ACoverageComponentDestructionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentDestruction setup: required Actor is null");
	}
	return !Actor.WasDestroyed && Actor.TestComp == nullptr;
}

bool Observe_ComponentDestruction_CopyIndependence(ACoverageComponentDestructionActor First, ACoverageComponentDestructionActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentDestruction setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentDestruction setup: required Second is null");
	}
	First.WasDestroyed = true;
	return First.WasDestroyed && !Second.WasDestroyed;
}
