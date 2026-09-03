/**
 * A default keyword overrides the inline initializer. C++ GetScore returns 20
 * (default 20 beats inline 10). A zero assign and two locals cover independence.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.DefaultOverridesInlineInitializerPriority
 * @Harness UClass
 * @Tag Feature.Inheritance.DefaultOverridesInlineInitializerPriority
 * @Provenance Theme: Feature.Inheritance. Positive default keyword overrides the inline initializer.
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultOverridesInlineInitializerPriority
 * @Provenance sha256 from theme-refs TS-FEAT-0009; lines 426-441.
 * @Provenance Oracle: GetScore executes and returns 20 (default 20 beats inline 10).
 * @Provenance Extra: Score after zero assign is 0; two locals independent. DefaultSafe.
 */

UCLASS()
class UDefaultPriorityCarrier : UObject
{
	UPROPERTY()
	int Score = 10;

	default Score = 20;

	/**
	 * Read Score, which the default keyword sets to 20 on a fresh instance.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultOverridesInlineInitializerPriority
	 * @Inputs none
	 * @Return Score, expected to be 20
	 */
	UFUNCTION()
	int GetScore()
	{
		return Score;
	}

	/**
	 * Observe that assigning Score to 0 is visible through GetScore.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultOverridesInlineInitializerPriority
	 * @Inputs Score = 0
	 * @Return GetScore(), expected to be 0
	 * @Boundary zero assign
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		Score = 0;
		return GetScore();
	}

	/**
	 * Observe that writing Score on this instance leaves another carrier untouched.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.DefaultOverridesInlineInitializerPriority
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this is 0 and the other stays 20
	 * @Param Second the other carrier, expected to stay at its default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UDefaultPriorityCarrier Second)
	{
		if (Second == nullptr)
		{
			throw("DefaultOverridesInlineInitializerPriority setup: required Second is null");
		}
		Score = 0;
		if (GetScore() != 0)
		{
			return false;
		}
		return Second.GetScore() == 20;
	}
}
