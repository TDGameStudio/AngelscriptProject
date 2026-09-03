/**
 * UIMin and UIMax metadata, including a combined Clamp plus UI range. C++ reflects
 * the meta keys on FProperty. The observers cover the declared defaults, a zero
 * write and copy independence.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.UIMinMaxMeta
 * @Harness UClass
 * @Tag Definitions.Meta.UIMinMaxMeta
 * @Provenance Theme: Definitions.Meta. WorldStory: UIMin/UIMax (and combined Clamp) meta.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::UIMinMaxMeta
 * @Provenance Oracle defaults: UIRangedInt 50, UIRangedFloat 0.5, UIRangedDouble 0.0, ComboRangedInt 50.
 * @Provenance Extra: write 0; copy independence. FixtureIsolated.
 */

UCLASS()
class ACoverageMetaUIRangeActor : AActor
{
	UPROPERTY(meta = (UIMin = "0", UIMax = "100"))
	int UIRangedInt = 50;

	UPROPERTY(meta = (UIMin = "0.0", UIMax = "1.0"))
	float UIRangedFloat = 0.5f;

	UPROPERTY(meta = (UIMin = "-180.0", UIMax = "180.0"))
	double UIRangedDouble = 0.0;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "255", UIMin = "0", UIMax = "100"))
	int ComboRangedInt = 50;

	/**
	 * Observe the UIRangedInt default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs none
	 * @Return 50
	 */
	UFUNCTION()
	int UIRangedIntDefault()
	{
		return UIRangedInt;
	}

	/**
	 * Observe the UIRangedFloat default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs none
	 * @Return 0.5
	 */
	UFUNCTION()
	float UIRangedFloatDefault()
	{
		return UIRangedFloat;
	}

	/**
	 * Observe the UIRangedDouble default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs none
	 * @Return 0.0
	 */
	UFUNCTION()
	double UIRangedDoubleDefault()
	{
		return UIRangedDouble;
	}

	/**
	 * Observe the ComboRangedInt default.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs none
	 * @Return 50
	 */
	UFUNCTION()
	int ComboRangedIntDefault()
	{
		return ComboRangedInt;
	}

	/**
	 * Observe that writing zero to the int ranges is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		UIRangedInt = 0;
		ComboRangedInt = 0;
		return UIRangedInt + ComboRangedInt;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.UIMinMaxMeta
	 * @Inputs a second actor
	 * @Return true when this reads 1 and the other still reads 50
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageMetaUIRangeActor Second)
	{
		if (Second is null)
		{
			throw("UIMinMaxMeta setup: required Second is null");
		}
		UIRangedInt = 1;
		Second.UIRangedInt = 50;
		if (UIRangedInt != 1)
		{
			return false;
		}
		return Second.UIRangedInt == 50;
	}
}
