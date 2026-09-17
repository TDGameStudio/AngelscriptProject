/**
 * @version v1
 * @summary Float and double UPROPERTY defaults: two left uninitialized and two carrying initializers. The observers confirm both groups hold their expected values.
 * @topic Language
 */
/**
 * @version root
 * @summary Float and double UPROPERTY defaults: two left uninitialized and two carrying initializers. The observers confirm both groups hold their expected values.
 * @topic Baseline
 */
UCLASS()
class ACoverageFloatDefaultsActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	UPROPERTY()
	float InitializedFloat = 1.25f;

	UPROPERTY()
	double InitializedDouble = 2.5;

	/**
	 * Observe that the uninitialized properties read as zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both uninitialised values are zero
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FloatDefaultsUninitializedZero()
	{
		if (!Math::IsNearlyEqual(FloatValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 0.0);
	}

	/**
	 * Observe that the initialized properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.25 and 2.5
	 * @Boundary initialized values
	 */
	UFUNCTION()
	bool FloatDefaultsInitializedBoundary()
	{
		if (!Math::IsNearlyEqual(InitializedFloat, 1.25))
		{
			return false;
		}

		return Math::IsNearlyEqual(InitializedDouble, 2.5);
	}
}
/** @end */
