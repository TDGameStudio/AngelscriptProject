/**
 * Script-side writes to float and double UPROPERTYs, first positive then
 * negative. The observers confirm the defaults and that both polarities
 * round-trip.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FloatFamilyWriteRoundTrip
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FloatFamilyWriteRoundTrip
 * @Provenance C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyWriteRoundTrip
 * @Provenance sha256=90e00c692f2bf27311657cd2e3c4d6ffd7e62c94a96c0894f2903a924478f83b; lines 196-206.
 * @Provenance Oracle: FloatValue 3.14159 then -2.71828; DoubleValue 1.4142135623730951 then -1.7320508075688772.
 * @Provenance Extra: default 0 before any write. FixtureIsolated. Script assignment is copy into UPROPERTY.
 */

UCLASS()
class ACoverageFloatWriteActor : AActor
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
	bool FloatWriteDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that positive then negative writes both round-trip.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both properties written positive then negative
	 * @Return true when all four reads match their written values
	 * @Boundary both polarities
	 */
	UFUNCTION()
	bool FloatWriteScriptRoundTripBoundary()
	{
		FloatValue = 3.14159f;
		DoubleValue = 1.4142135623730951;

		if (!Math::IsNearlyEqual(FloatValue, 3.14159, 0.00001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DoubleValue, 1.4142135623730951, 0.00001))
		{
			return false;
		}

		FloatValue = -2.71828f;
		DoubleValue = -1.7320508075688772;

		if (!Math::IsNearlyEqual(FloatValue, -2.71828, 0.00001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, -1.7320508075688772, 0.00001);
	}
}
