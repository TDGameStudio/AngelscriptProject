/**
 * @version v1
 * @summary A FVector2D passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover the empty argument.
 * @topic Math
 */
/**
 * @version root
 * @summary A FVector2D passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover the empty argument.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Scale a vector in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a vector and a scale factor
	 * @Return the vector scaled in place
	 * @Param v the vector to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleVector(FVector2D&inout v, float scale)
	{
		v = v * scale;
	}

	/**
	 * Observe that the caller's vector is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FVector2D(30, 60)
	 */
	UFUNCTION()
	bool ScaleVectorNominal()
	{
		FVector2D Value = FVector2D(10, 20);
		ScaleVector(Value, 3.0);
		return Value.Equals(FVector2D(30, 60), 0.001);
	}

	/**
	 * Observe that scaling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a default-constructed vector
	 * @Return true when the value still equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleVectorDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		ScaleVector(Empty, 3.0);
		return Empty.Equals(FVector2D::ZeroVector, 0.001);
	}

	/**
	 * Observe that scaling one vector leaves a separate copy untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a vector and a separate copy of it
	 * @Return true when the scaled one reads (30, 60) and the copy still reads (10, 20)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ScaleVectorCopyIndependence()
	{
		FVector2D Value = FVector2D(10, 20);
		FVector2D Other = Value;
		ScaleVector(Value, 3.0);

		if (!Value.Equals(FVector2D(30, 60), 0.001))
		{
			return false;
		}
		return Other.Equals(FVector2D(10, 20), 0.001);
	}
}
/** @end */
