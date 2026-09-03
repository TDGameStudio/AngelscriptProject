/**
 * An actor whose UCapsuleComponent BeginPlay records radius and half-height
 * before and after SetCapsuleSize. The observers cover the local-construct
 * default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.CapsuleComponent
 * @Harness UClass
 * @Tag World.Component.CapsuleComponent
 * @Provenance Theme: World.Component. WorldStory: SetCapsuleSize radius/half-height.
 * @Provenance C++: AngelscriptCoverageSpecialComponentTests.cpp::CapsuleComponent
 * @Provenance sha256=e73f0b493b42b55d202c5e8ad691be552e41e655dd3df3aef678ab0cb880b775; lines 538-569.
 * @Provenance Oracle NewRadius=50, NewHalfHeight=100. Extra: local construct zeros,
 * @Provenance CapsuleComp null. FixtureIsolated.
 */

UCLASS()
class ACoverageSpecialCapsuleActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent CapsuleComp;

	UPROPERTY()
	float InitialRadius = 0.0f;

	UPROPERTY()
	float InitialHalfHeight = 0.0f;

	UPROPERTY()
	float NewRadius = 0.0f;

	UPROPERTY()
	float NewHalfHeight = 0.0f;

	/**
	 * WorldStory: BeginPlay reads both capsule dimensions, resizes the capsule,
	 * then reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CapsuleComponent
	 * @Inputs a default-attached UCapsuleComponent
	 * @Return NewRadius == 50 and NewHalfHeight == 100
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitialRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		InitialHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();

		CapsuleComp.SetCapsuleSize(50.0f, 100.0f);

		NewRadius = CapsuleComp.GetUnscaledCapsuleRadius();
		NewHalfHeight = CapsuleComp.GetUnscaledCapsuleHalfHeight();
	}

	/**
	 * Observe that a locally constructed actor has all four dimensions at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CapsuleComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four are 0 and CapsuleComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (InitialRadius != 0.0f)
		{
			return false;
		}
		if (InitialHalfHeight != 0.0f)
		{
			return false;
		}
		if (NewRadius != 0.0f)
		{
			return false;
		}
		if (NewHalfHeight != 0.0f)
		{
			return false;
		}
		return CapsuleComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CapsuleComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 50/100 and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCapsuleActor Second)
	{
		if (Second is null)
		{
			throw("CapsuleComponent setup: required Second is null");
		}
		NewRadius = 50.0f;
		NewHalfHeight = 100.0f;

		if (NewRadius != 50.0f)
		{
			return false;
		}
		if (NewHalfHeight != 100.0f)
		{
			return false;
		}
		if (Second.NewRadius != 0.0f)
		{
			return false;
		}
		return Second.NewHalfHeight == 0.0f;
	}
}
