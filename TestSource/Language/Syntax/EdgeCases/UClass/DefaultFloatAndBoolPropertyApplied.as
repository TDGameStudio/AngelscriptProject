/**
 * A float and a bool UPROPERTY whose CDO defaults are set with `default`
 * statements. The verifier returns distinct codes so a failure names which
 * default was missed.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.DefaultFloatAndBoolPropertyApplied
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.DefaultFloatAndBoolPropertyApplied
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFloatAndBoolPropertyApplied
 * @Provenance sha256=d774accb145943002fef49bba4c55d2c0d13697889e90a79e77163149690fc08; lines 167-190.
 * @Provenance Oracle: VerifyDefaults returns 42. Extra: MyFloat=0 returns 1; bEnabled=false
 * @Provenance returns 2. DefaultSafe.
 */

UCLASS()
class UDefaultFloatBoolCarrier : UObject
{
	UPROPERTY()
	float MyFloat;

	UPROPERTY()
	bool bEnabled;

	default MyFloat = 3.14f;
	default bEnabled = true;

	/**
	 * Verifies both defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two defaulted UPROPERTYs
	 * @Return 42 when both hold, otherwise 1 or 2 naming the failed check
	 */
	UFUNCTION()
	int VerifyDefaults()
	{
		if (MyFloat < 3.13f || MyFloat > 3.15f)
		{
			return 1;
		}
		if (!bEnabled)
		{
			return 2;
		}
		return 42;
	}

	/**
	 * Observe that both defaults were applied.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when verification returns 42
	 */
	UFUNCTION()
	bool DefaultFloatAndBoolVerifyPasses()
	{
		return VerifyDefaults() == 42;
	}

	/**
	 * Observe the float boundary where the default no longer holds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs MyFloat set to 0
	 * @Return true when verification returns 1
	 * @Boundary zero float
	 */
	UFUNCTION()
	bool DefaultFloatZeroBoundaryFailsVerification()
	{
		MyFloat = 0.0f;
		return VerifyDefaults() == 1;
	}

	/**
	 * Observe the bool boundary where the default no longer holds.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs bEnabled set to false
	 * @Return true when verification returns 2
	 * @Boundary disabled flag
	 */
	UFUNCTION()
	bool DefaultBoolDisabledBoundaryFailsVerification()
	{
		bEnabled = false;
		return VerifyDefaults() == 2;
	}
}
