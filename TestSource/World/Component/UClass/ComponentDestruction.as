/**
 * A component destroyed from the owning actor's Tick. C++ verifies WasDestroyed
 * by path. The observers cover the local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.Destruction
 * @Harness UClass
 * @Tag World.Component.ComponentDestruction
 * @Provenance Theme: World.Component. WorldStory: DestroyComponent from Tick.
 * @Provenance C++: AngelscriptCoverageComponentTests.cpp::ComponentDestruction
 * @Provenance sha256=5f1252444e519a8b56e931d356d9418e48c1ca8b920b1ff0ffd72f6339ce992d; lines 2687-2712.
 * @Provenance Oracle VerifyByPath WasDestroyed=true after Tick. Extra: local construct
 * @Provenance WasDestroyed false, TestComp null. FixtureIsolated.
 */

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

	/**
	 * WorldStory: the first Tick destroys the component and records that it did.
	 *
	 * @Kind WorldStory
	 * @Covers Component.Destruction
	 * @Inputs the default-attached component
	 * @Return WasDestroyed true once the component has been destroyed
	 * @Param DeltaTime the frame delta, unused
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp != nullptr && !TestComp.IsBeingDestroyed())
		{
			TestComp.DestroyComponent();
			WasDestroyed = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has not destroyed anything.
	 *
	 * @Kind Observe
	 * @Covers Component.Destruction
	 * @Inputs an actor that has not ticked
	 * @Return true when the flag is clear and TestComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (WasDestroyed)
		{
			return false;
		}
		return TestComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.Destruction
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flagged and the other is not
	 * @Param Second the other actor, expected to stay unflagged
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageComponentDestructionActor Second)
	{
		if (Second is null)
		{
			throw("ComponentDestruction setup: required Second is null");
		}
		WasDestroyed = true;

		if (!WasDestroyed)
		{
			return false;
		}
		return !Second.WasDestroyed;
	}
}
