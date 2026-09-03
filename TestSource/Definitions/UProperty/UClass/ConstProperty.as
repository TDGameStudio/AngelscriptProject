/**
 * A const UPROPERTY currently compiles because C++ wraps the failure in #if 0
 * (structural-validation-absent). The observers cover ConstVal 5 and that a
 * local snapshot mutation does not change the property.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.ConstProperty
 * @Harness UClass
 * @Tag Definitions.UProperty.ConstProperty
 * @Provenance Theme: Definitions.UProperty. CSV NegativeDiagnostic. C++ wraps AssertFailsToCompile
 * @Provenance in #if 0 (#as-engine-behavior: structural-validation-absent) so a const UPROPERTY
 * @Provenance currently compiles.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Negative
 * @Provenance UPropTN_ConstProp; lines 578-584;
 * @Provenance sha256=805d1636cce9a114c1392ac73cdb4658ff3ef11f0fc3cb353311a640af4006df.
 * @Provenance Oracle: ConstVal default is 5. Extra: 5 is the only initializer; no mutation API.
 * @Provenance FixtureIsolated.
 */

class AUPropConstPropActor : AActor
{
	UPROPERTY()
	const int ConstVal = 5;

	/**
	 * Observe the default ConstVal of 5.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs none
	 * @Return true when ConstVal is 5
	 */
	UFUNCTION()
	bool ConstValDefault()
	{
		return ConstVal == 5;
	}

	/**
	 * Observe that ConstVal is not the empty 0 boundary.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs none
	 * @Return true when ConstVal is not 0
	 * @Boundary non-zero initializer
	 */
	UFUNCTION()
	bool ConstValNotZeroBoundary()
	{
		return ConstVal != 0;
	}

	/**
	 * Observe that mutating a local copy leaves ConstVal at 5.
	 *
	 * @Kind Observe
	 * @Covers UProperty.ConstProperty
	 * @Inputs a local copy written to 0
	 * @Return 5 from ConstVal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int ConstValCopySnapshot()
	{
		int Copy = ConstVal;
		Copy = 0;
		return ConstVal;
	}
}
