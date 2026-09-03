/**
 * Vectors returned from functions: a constant, a literal and a computed sum. C++ executes
 * each entrypoint and compares the result with the native equivalent, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty default and
 * the independence of a copy.
 *
 * @Theme Math.FVector2D
 * @Subject FVector2D.FunctionReturnValues
 * @Harness Function
 * @Tag Math.FVector2D.FunctionReturnValues
 * @Namespace FVector2DTest
 * @Provenance Theme: Gameplay.FVector2D. Positive return-value oracles.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionReturnValues
 * @Provenance Oracle: ReturnZeroVector ZeroVector; ReturnCustomVector (50,75);
 * @Provenance ReturnComputedVector (15,30). Extra: empty ZeroVector; copy independence of
 * @Provenance custom return. DefaultSafe.
 */

namespace FVector2DTest
{
	/**
	 * Return a vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return the zero vector
	 */
	UFUNCTION()
	FVector2D ReturnZeroVector()
	{
		return FVector2D::ZeroVector;
	}

	/**
	 * Return a literal vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector2D(50, 75)
	 */
	UFUNCTION()
	FVector2D ReturnCustomVector()
	{
		return FVector2D(50, 75);
	}

	/**
	 * Return a vector computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector2D(15, 30)
	 */
	UFUNCTION()
	FVector2D ReturnComputedVector()
	{
		FVector2D a = FVector2D(10, 20);
		FVector2D b = FVector2D(5, 10);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the zero vector
	 */
	UFUNCTION()
	bool ReturnZeroVectorNominal()
	{
		return ReturnZeroVector().Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector2D(50, 75)
	 */
	UFUNCTION()
	bool ReturnCustomVectorNominal()
	{
		return ReturnCustomVector().Equals(FVector2D(50, 75));
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector2D(15, 30)
	 */
	UFUNCTION()
	bool ReturnComputedVectorNominal()
	{
		return ReturnComputedVector().Equals(FVector2D(15, 30));
	}

	/**
	 * Observe that an empty vector equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnZeroVectorDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Empty.Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating a copy leaves the returned vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs the returned vector and a mutated copy of it
	 * @Return true when the returned one still reads (50, 75) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomVectorCopyIndependence()
	{
		FVector2D Original = ReturnCustomVector();
		FVector2D Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector2D(50, 75)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
