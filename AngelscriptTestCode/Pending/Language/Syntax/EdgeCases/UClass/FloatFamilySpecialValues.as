/**
 * @version v1
 * @summary NaN and infinity handling on float and double UPROPERTYs. The C++ runner writes each special through SetByPath and reads it back through VerifyByPath; the observers confirm the defaults are finite before any write.
 * @topic Language
 */
/**
 * @version root
 * @summary NaN and infinity handling on float and double UPROPERTYs. The C++ runner writes each special through SetByPath and reads it back through VerifyByPath; the observers confirm the defaults are finite before any write.
 * @topic Baseline
 */
UCLASS()
class ACoverageFloatSpecialActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	/**
	 * Observe that both properties start finite and zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both values are finite, zero and not NaN
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatSpecialDefaultFiniteEmpty()
	{
		if (!Math::IsFinite(FloatValue))
		{
			return false;
		}

		if (!Math::IsFinite(DoubleValue))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(DoubleValue, 0.0))
		{
			return false;
		}

		if (Math::IsNaN(FloatValue))
		{
			return false;
		}

		return !Math::IsNaN(DoubleValue);
	}
}
/** @end */
