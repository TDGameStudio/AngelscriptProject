/**
 * ClampMin and ClampMax metadata on int, float and double properties. C++ reflects
 * the meta keys on FProperty. The observers cover the declared defaults, a zero
 * write and copy independence.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.ClampMinMaxMeta
 * @Harness UClass
 * @Tag Definitions.Meta.ClampMinMaxMeta
 * @Provenance Theme: Definitions.Meta. WorldStory: ClampMin/ClampMax meta on numeric properties.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::ClampMinMaxMeta
 * @Provenance Oracle defaults: ClampedInt 50, ClampedFloat 0.5, ClampedDouble 0.0, OnlyMinInt 10, OnlyMaxInt 100.
 * @Provenance Extra: write 0 / copy independence. FixtureIsolated. Keep C++ property names.
 */

UCLASS()
class ACoverageMetaClampActor : AActor
{
	UPROPERTY(meta = (ClampMin = "0", ClampMax = "100"))
	int ClampedInt = 50;

	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float ClampedFloat = 0.5f;

	UPROPERTY(meta = (ClampMin = "-10.0", ClampMax = "10.0"))
	double ClampedDouble = 0.0;

	UPROPERTY(meta = (ClampMin = "0"))
	int OnlyMinInt = 10;

	UPROPERTY(meta = (ClampMax = "255"))
	int OnlyMaxInt = 100;

	/**
	 * Observe the ClampedInt default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 50
	 */
	UFUNCTION()
	int ClampedIntDefault()
	{
		return ClampedInt;
	}

	/**
	 * Observe the ClampedFloat default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 0.5
	 */
	UFUNCTION()
	float ClampedFloatDefault()
	{
		return ClampedFloat;
	}

	/**
	 * Observe the ClampedDouble default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 0.0
	 */
	UFUNCTION()
	double ClampedDoubleDefault()
	{
		return ClampedDouble;
	}

	/**
	 * Observe the OnlyMinInt default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	int OnlyMinIntDefault()
	{
		return OnlyMinInt;
	}

	/**
	 * Observe the OnlyMaxInt default.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int OnlyMaxIntDefault()
	{
		return OnlyMaxInt;
	}

	/**
	 * Observe that writing zero to the int properties is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		ClampedInt = 0;
		OnlyMinInt = 0;
		OnlyMaxInt = 0;
		return ClampedInt + OnlyMinInt + OnlyMaxInt;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.ClampMinMaxMeta
	 * @Inputs a second actor
	 * @Return true when this reads 1 and the other still reads 50
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageMetaClampActor Second)
	{
		if (Second is null)
		{
			throw("ClampMinMaxMeta setup: required Second is null");
		}
		ClampedInt = 1;
		Second.ClampedInt = 50;
		if (ClampedInt != 1)
		{
			return false;
		}
		return Second.ClampedInt == 50;
	}
}
