/**
 * FVector2Ds written through out parameters, where the callee fills in the caller's
 * variable. C++ executes each entrypoint and checks the values written, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty value before
 * the write and the independence of two out values.
 *
 * @Theme Math.FVector2D
 * @Subject FVector2D.FunctionParametersOut
 * @Harness Function
 * @Tag Math.FVector2D.FunctionParametersOut
 * @Namespace FVector2DTest
 * @Provenance Theme: Gameplay.FVector2D. Positive &out write oracles.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersOut
 * @Provenance Oracle: WriteVector -> (100,200); WriteMultipleVectors A (1,0) B (0,1).
 * @Provenance Extra: empty ZeroVector before write; copy independence of two out values.
 * @Provenance DefaultSafe.
 */

namespace FVector2DTest
{
	/**
	 * Write a fixed vector into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FVector2D(100, 200)
	 * @Param v the vector to write into
	 */
	UFUNCTION()
	void WriteVector(FVector2D&out v)
	{
		v = FVector2D(100, 200);
	}

	/**
	 * Write two axis vectors into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as (1, 0), the second as (0, 1)
	 * @Param a the first vector to write into
	 * @Param b the second vector to write into
	 */
	UFUNCTION()
	void WriteMultipleVectors(FVector2D&out a, FVector2D&out b)
	{
		a = FVector2D(1, 0);
		b = FVector2D(0, 1);
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FVector2D(100, 200)
	 */
	UFUNCTION()
	bool WriteVectorNominal()
	{
		FVector2D OutValue;
		WriteVector(OutValue);
		return OutValue.Equals(FVector2D(100, 200));
	}

	/**
	 * Observe that both out parameters receive their own axis.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads (1, 0) and the second (0, 1)
	 */
	UFUNCTION()
	bool WriteMultipleVectorsNominal()
	{
		FVector2D OutA;
		FVector2D OutB;
		WriteMultipleVectors(OutA, OutB);

		if (!OutA.Equals(FVector2D(1, 0)))
		{
			return false;
		}
		return OutB.Equals(FVector2D(0, 1));
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteVectorDefaultEmpty()
	{
		FVector2D Empty;
		return Empty.Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads (0, 1)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleVectorsCopyIndependence()
	{
		FVector2D OutA;
		FVector2D OutB;
		WriteMultipleVectors(OutA, OutB);
		OutA.X = 0.0;
		return OutB.Equals(FVector2D(0, 1));
	}
}
