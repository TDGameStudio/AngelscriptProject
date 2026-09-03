/**
 * Writing a FTransform UPROPERTY and reading it back across a positive translation, a
 * scale and a negative translation. C++ sets and verifies the value by path, so the
 * UPROPERTY name is part of the contract and is kept verbatim. The observers cover the
 * identity default and the independence of two instances.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.WriteRoundTrip
 * @Harness UClass
 * @Tag Gameplay.FTransform.FTransformWriteRoundTrip
 * @Provenance Theme: Gameplay.FTransform. WorldStory write round-trip of Translation/Scale3D.
 * @Provenance C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformWriteRoundTrip
 * @Provenance Oracle SetByPath/VerifyByPath: Translation (100,200,300) then Scale3D (2,3,4)
 * @Provenance then negative Translation (-50,-100,-150). Extra: default identity empty;
 * @Provenance zero Translation boundary. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFTransformWriteActor : AActor
{
	UPROPERTY()
	FTransform TransformValue;

	/**
	 * Observe that an untouched property is the identity transform.
	 *
	 * @Kind Observe
	 * @Covers FTransform.WriteRoundTrip
	 * @Inputs none
	 * @Return true when the translation is the origin and the scale is one
	 * @Boundary identity default
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TransformValue.GetLocation().X != 0.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Y != 0.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Z != 0.0)
		{
			return false;
		}
		return TransformValue.GetScale3D().X == 1.0;
	}

	/**
	 * Observe that a positive translation reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FTransform.WriteRoundTrip
	 * @Inputs none
	 * @Return true when the translation reads (100, 200, 300)
	 */
	UFUNCTION()
	bool WriteTranslation100()
	{
		TransformValue.SetLocation(FVector(100, 200, 300));

		if (TransformValue.GetLocation().X != 100.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Y != 200.0)
		{
			return false;
		}
		return TransformValue.GetLocation().Z == 300.0;
	}

	/**
	 * Observe that a scale write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FTransform.WriteRoundTrip
	 * @Inputs none
	 * @Return true when the scale reads (2, 3, 4)
	 */
	UFUNCTION()
	bool WriteScale234()
	{
		TransformValue.SetScale3D(FVector(2, 3, 4));

		if (TransformValue.GetScale3D().X != 2.0)
		{
			return false;
		}
		if (TransformValue.GetScale3D().Y != 3.0)
		{
			return false;
		}
		return TransformValue.GetScale3D().Z == 4.0;
	}

	/**
	 * Observe that a negative translation reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FTransform.WriteRoundTrip
	 * @Inputs none
	 * @Return true when the translation reads (-50, -100, -150)
	 */
	UFUNCTION()
	bool WriteNegativeTranslation()
	{
		TransformValue.SetLocation(FVector(-50, -100, -150));

		if (TransformValue.GetLocation().X != -50.0)
		{
			return false;
		}
		if (TransformValue.GetLocation().Y != -100.0)
		{
			return false;
		}
		return TransformValue.GetLocation().Z == -150.0;
	}

	/**
	 * Observe that writing one instance leaves another instance at the identity.
	 *
	 * @Kind Observe
	 * @Covers FTransform.WriteRoundTrip
	 * @Inputs a second actor
	 * @Return true when this instance reads 100 and the other still reads 0
	 * @Param Second the other actor, expected to stay at the identity
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFTransformWriteActor Second)
	{
		if (Second is null)
		{
			throw("FTransformWriteRoundTrip setup: required Second is null");
		}
		TransformValue.SetLocation(FVector(100, 200, 300));

		if (TransformValue.GetLocation().X != 100.0)
		{
			return false;
		}
		return Second.TransformValue.GetLocation().X == 0.0;
	}
}
