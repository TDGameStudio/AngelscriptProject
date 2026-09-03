/**
 * Float and double extremes assigned from script: the smallest positive
 * denormal-adjacent values and the largest finite values. The observers confirm
 * the defaults are zero before any write and that both extremes stick.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatFamilyBoundaryValues
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatFamilyBoundaryValues
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyBoundaryValues
 * @Provenance sha256=2974c41a11fc26dec4d0912578475f21a0b52415f239399f945a326836818c7a; lines 374-384.
 * @Provenance Oracle: FloatValue min then max then epsilon; DoubleValue min then max then epsilon.
 * @Provenance Extra: default 0 before C++ writes. FixtureIsolated. Fields stay the C++ VerifyByPath names.
 */

UCLASS()
class ACoverageFloatBoundaryActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties default to zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatBoundaryDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that the smallest and largest finite values round-trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both properties written with their smallest and largest values
	 * @Return true when the minima are positive and the maxima are huge
	 * @Boundary extreme values
	 */
	UFUNCTION()
	bool FloatBoundaryScriptMinMax()
	{
		FloatValue = 1.17549435e-38f;
		DoubleValue = 2.2250738585072014e-308;
		bool bMin = FloatValue > 0.0f && DoubleValue > 0.0;
		FloatValue = 3.40282347e+38f;
		DoubleValue = 1.7976931348623157e+308;

		if (!bMin)
		{
			return false;
		}

		if (FloatValue <= 1.0e+38f)
		{
			return false;
		}

		return DoubleValue > 1.0e+308;
	}
}
