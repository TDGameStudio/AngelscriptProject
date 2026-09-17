/**
 * @version v1
 * @summary Script-side writes to float and double UPROPERTYs, first positive then negative. The observers confirm the defaults and that both polarities round-trip.
 * @topic Language
 */
/**
 * @version root
 * @summary Script-side writes to float and double UPROPERTYs, first positive then negative. The observers confirm the defaults and that both polarities round-trip.
 * @topic Baseline
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
/** @end */
