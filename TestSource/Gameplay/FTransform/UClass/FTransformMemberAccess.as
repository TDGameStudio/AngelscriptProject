/**
 * SetLocation and SetScale3D writing a FTransform UPROPERTY during BeginPlay. C++
 * verifies the translation and the scale by path, so the UPROPERTY name is part of the
 * contract and is kept verbatim. The observers cover the identity default and the
 * independence of two instances.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.MemberAccess
 * @Harness UClass
 * @Tag Gameplay.FTransform.FTransformMemberAccess
 * @Provenance Theme: Gameplay.FTransform. WorldStory SetLocation/SetScale3D member access.
 * @Provenance C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformMemberAccess
 * @Provenance Oracle after BeginPlay: MyTransform.Translation (100,200,300);
 * @Provenance MyTransform.Scale3D (5,5,5). Extra: default identity empty before BeginPlay.
 * @Provenance FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFTransformMemberActor : AActor
{
	UPROPERTY()
	FTransform MyTransform;

	/**
	 * WorldStory: BeginPlay writes the translation and the scale onto the property.
	 *
	 * @Kind WorldStory
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return the translation set to (100, 200, 300) and the scale to (5, 5, 5)
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MyTransform.SetLocation(FVector(100, 200, 300));
		MyTransform.SetScale3D(FVector(5, 5, 5));
	}

	/**
	 * Observe that an untouched actor holds the identity transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when the translation is the origin and the scale is all ones
	 * @Boundary identity default
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (MyTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		if (MyTransform.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (MyTransform.GetLocation().Z != 0.0)
		{
			return false;
		}
		if (MyTransform.GetScale3D().X != 1.0)
		{
			return false;
		}
		if (MyTransform.GetScale3D().Y != 1.0)
		{
			return false;
		}
		return MyTransform.GetScale3D().Z == 1.0;
	}

	/**
	 * Observe that BeginPlay lands both the translation and the scale.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs none
	 * @Return true when the translation reads (100, 200, 300) and the scale reads (5, 5, 5)
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		BeginPlay();

		if (MyTransform.GetLocation().X != 100.0)
		{
			return false;
		}
		if (MyTransform.GetLocation().Y != 200.0)
		{
			return false;
		}
		if (MyTransform.GetLocation().Z != 300.0)
		{
			return false;
		}
		if (MyTransform.GetScale3D().X != 5.0)
		{
			return false;
		}
		if (MyTransform.GetScale3D().Y != 5.0)
		{
			return false;
		}
		return MyTransform.GetScale3D().Z == 5.0;
	}

	/**
	 * Observe that driving one instance leaves another instance at the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.MemberAccess
	 * @Inputs a second actor
	 * @Return true when this instance reads 100 and the other still reads 0 with a unit scale
	 * @Param Second the other actor, expected to stay at the identity
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFTransformMemberActor Second)
	{
		if (Second is null)
		{
			throw("FTransformMemberAccess setup: required Second is null");
		}
		BeginPlay();

		if (MyTransform.GetLocation().X != 100.0)
		{
			return false;
		}
		if (Second.MyTransform.GetLocation().X != 0.0)
		{
			return false;
		}
		return Second.MyTransform.GetScale3D().X == 1.0;
	}
}
