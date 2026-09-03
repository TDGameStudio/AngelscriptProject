/**
 * SetSphereRadius and GetUnscaledSphereRadius on a sphere component. C++ verifies
 * the new radius. The observers cover the local-construct default and copy
 * independence.
 *
 * @Theme World.Component
 * @Subject Component.SphereComponent
 * @Harness UClass
 * @Tag World.Component.SphereComponent
 * @Provenance Theme: World.Component. WorldStory: SetSphereRadius / GetUnscaledSphereRadius.
 * @Provenance C++: AngelscriptCoverageSpecialComponentTests.cpp::SphereComponent
 * @Provenance sha256=53a5257362a08efedf9bb9c9933937f48990c23e29ab538c79efebb5bd82d49e; lines 472-495.
 * @Provenance Oracle NewRadius=150. Extra: local construct Initial/NewRadius 0, SphereComp null.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageSpecialSphereActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	/**
	 * WorldStory: BeginPlay reads the starting radius, resizes the sphere, then reads
	 * it back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.SphereComponent
	 * @Inputs a default-attached USphereComponent
	 * @Return NewRadius == 150
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = SphereComp.GetUnscaledSphereRadius();

		SphereComp.SetSphereRadius(150.0f);

		NewRadius = SphereComp.GetUnscaledSphereRadius();
	}

	/**
	 * Observe that a locally constructed actor has no radii and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.SphereComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when both radii are 0 and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialRadius != 0.0f)
		{
			return false;
		}
		if (NewRadius != 0.0f)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.SphereComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the new radius and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialSphereActor Second)
	{
		if (Second is null)
		{
			throw("SphereComponent setup: required Second is null");
		}
		NewRadius = 150.0f;

		if (NewRadius != 150.0f)
		{
			return false;
		}
		return Second.NewRadius == 0.0f;
	}
}
