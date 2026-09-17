/**
 * @version v1
 * @summary UFUNCTIONs mutating float and double UPROPERTYs: a paired assign and two accumulating adds. The observers confirm the defaults, the nominal accumulate-after-assign sequence, and the zero-delta boundary.
 * @topic Language
 */
/**
 * @version root
 * @summary UFUNCTIONs mutating float and double UPROPERTYs: a paired assign and two accumulating adds. The observers confirm the defaults, the nominal accumulate-after-assign sequence, and the zero-delta boundary.
 * @topic Baseline
 */
UCLASS()
class ACoverageFloatScriptMutationActor : AActor
{
	UPROPERTY()
	float FloatValue = 1.5f;

	UPROPERTY()
	double DoubleValue = 2.25;

	/**
	 * Assigns both properties at once.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the new values
	 * @Return nothing; both properties are overwritten
	 * @Param NewFloat the new float value
	 * @Param NewDouble the new double value
	 */
	UFUNCTION()
	void AssignValues(float NewFloat, double NewDouble)
	{
		FloatValue = NewFloat;
		DoubleValue = NewDouble;
	}

	/**
	 * Adds a delta to the float property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the delta to add
	 * @Return the updated float value
	 * @Param Delta the delta to add
	 */
	UFUNCTION()
	float AddToFloat(float Delta)
	{
		FloatValue += Delta;
		return FloatValue;
	}

	/**
	 * Adds a delta to the double property.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the delta to add
	 * @Return the updated double value
	 * @Param Delta the delta to add
	 */
	UFUNCTION()
	double AddToDouble(double Delta)
	{
		DoubleValue += Delta;
		return DoubleValue;
	}

	/**
	 * Observe that both properties hold their initializers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the values are 1.5 and 2.25
	 * @Boundary default values
	 */
	UFUNCTION()
	bool FloatMutationDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(FloatValue, 1.5))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 2.25);
	}

	/**
	 * Observe the assign-then-accumulate sequence.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AssignValues followed by both adds
	 * @Return true when both returns and both properties match
	 */
	UFUNCTION()
	bool FloatMutationNominal()
	{
		AssignValues(12.5f, 42.75);
		float AddedF = AddToFloat(0.25f);
		double AddedD = AddToDouble(0.125);

		if (!Math::IsNearlyEqual(AddedF, 12.75, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(FloatValue, 12.75, 0.001))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(AddedD, 42.875, 0.0001))
		{
			return false;
		}

		return Math::IsNearlyEqual(DoubleValue, 42.875, 0.0001);
	}

	/**
	 * Observe that a zero delta leaves the assigned values unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs AssignValues followed by zero deltas
	 * @Return true when both returns equal the assigned values
	 * @Boundary zero delta
	 */
	UFUNCTION()
	bool FloatMutationZeroDeltaBoundary()
	{
		AssignValues(12.5f, 42.75);
		float AddedF = AddToFloat(0.0f);
		double AddedD = AddToDouble(0.0);

		if (!Math::IsNearlyEqual(AddedF, 12.5, 0.001))
		{
			return false;
		}

		return Math::IsNearlyEqual(AddedD, 42.75, 0.001);
	}
}
/** @end */
