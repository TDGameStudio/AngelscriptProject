/**
 * A FVector passed by mutable reference and scaled in place. C++ executes the entrypoint
 * and checks the value written back, so the name is part of the contract and is kept
 * verbatim. The observers cover the empty argument and the independence of a separate
 * vector.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.FunctionParametersInOut
 * @Harness Function
 * @Tag Gameplay.FVector.FunctionParametersInOut
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive &inout scale oracle.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersInOut
 * @Provenance Oracle: ScaleVector((1,2,3), 2.0) -> (2,4,6). Extra: empty ZeroVector stays
 * @Provenance zero; copy independence of a separate vector. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Scale a vector in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a vector and a scale factor
	 * @Return the vector scaled in place
	 * @Param v the vector to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleVector(FVector&inout v, float scale)
	{
		v = v * scale;
	}

	/**
	 * Observe that the caller's vector is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FVector(2, 4, 6)
	 */
	UFUNCTION()
	bool ScaleVectorNominal()
	{
		FVector Value = FVector(1, 2, 3);
		ScaleVector(Value, 2.0);
		return Value.Equals(FVector(2, 4, 6), 0.001);
	}

	/**
	 * Observe that scaling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a default-constructed vector
	 * @Return true when the value still equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleVectorDefaultEmpty()
	{
		FVector Empty = FVector();
		ScaleVector(Empty, 2.0);
		return Empty.Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that scaling one vector leaves a separate copy untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a vector and a separate copy of it
	 * @Return true when the scaled one reads (2, 4, 6) and the copy still reads (1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ScaleVectorCopyIndependence()
	{
		FVector Value = FVector(1, 2, 3);
		FVector Other = Value;
		ScaleVector(Value, 2.0);

		if (!Value.Equals(FVector(2, 4, 6), 0.001))
		{
			return false;
		}
		return Other.Equals(FVector(1, 2, 3), 0.001);
	}
}
