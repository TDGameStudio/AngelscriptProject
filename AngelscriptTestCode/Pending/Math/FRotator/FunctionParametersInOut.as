/**
 * @version v1
 * @summary A FRotator passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover a zero scale, the.
 * @topic Math
 */
/**
 * @version root
 * @summary A FRotator passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover a zero scale, the.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Scale a rotator in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a rotator and a scale factor
	 * @Return the rotator scaled in place
	 * @Param r the rotator to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleRotator(FRotator&inout r, float scale)
	{
		r = r * scale;
	}

	/**
	 * Observe that the caller's rotator is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FRotator(20, 40, 60)
	 */
	UFUNCTION()
	bool ScaleRotatorNominal()
	{
		FRotator Value = FRotator(10, 20, 30);
		ScaleRotator(Value, 2.0);
		return Value == FRotator(20, 40, 60);
	}

	/**
	 * Observe that a zero scale collapses the rotator to the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a rotator scaled by zero
	 * @Return true when the value equals the zero rotator
	 * @Boundary zero scale
	 */
	UFUNCTION()
	bool ScaleRotatorZeroScale()
	{
		FRotator Value = FRotator(10, 20, 30);
		ScaleRotator(Value, 0.0);
		return Value == FRotator::ZeroRotator;
	}

	/**
	 * Observe that scaling an empty rotator stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersInOut
	 * @Inputs a default-constructed rotator
	 * @Return true when the value still equals the zero rotator
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleRotatorDefaultEmpty()
	{
		FRotator Value = FRotator();
		ScaleRotator(Value, 2.0);
		return Value == FRotator::ZeroRotator;
	}
}
/** @end */
