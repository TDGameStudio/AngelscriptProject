/**
 * FVectors written through out parameters, where the callee fills in the caller's
 * variable. C++ executes each entrypoint and checks the values written, so those names are
 * part of the contract and are kept verbatim. The observers cover the empty value before
 * the write and the independence of two out values.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.FunctionParametersOut
 * @Harness Function
 * @Tag Gameplay.FVector.FunctionParametersOut
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive &out write oracles.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersOut
 * @Provenance Oracle: WriteVector -> (10,20,30); WriteMultipleVectors A ForwardVector
 * @Provenance (1,0,0) B UpVector (0,0,1). Extra: empty ZeroVector before write;
 * @Provenance copy independence of two out values. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Write a fixed vector into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FVector(10, 20, 30)
	 * @Param v the vector to write into
	 */
	UFUNCTION()
	void WriteVector(FVector&out v)
	{
		v = FVector(10, 20, 30);
	}

	/**
	 * Write two named directions into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as the forward vector, the second as the up vector
	 * @Param a the first vector to write into
	 * @Param b the second vector to write into
	 */
	UFUNCTION()
	void WriteMultipleVectors(FVector&out a, FVector&out b)
	{
		a = FVector::ForwardVector;
		b = FVector::UpVector;
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FVector(10, 20, 30)
	 */
	UFUNCTION()
	bool WriteVectorNominal()
	{
		FVector OutValue;
		WriteVector(OutValue);
		return OutValue.Equals(FVector(10, 20, 30));
	}

	/**
	 * Observe that both out parameters receive their own direction.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads the forward vector and the second the up vector
	 */
	UFUNCTION()
	bool WriteMultipleVectorsNominal()
	{
		FVector OutA;
		FVector OutB;
		WriteMultipleVectors(OutA, OutB);

		if (!OutA.Equals(FVector::ForwardVector))
		{
			return false;
		}
		return OutB.Equals(FVector::UpVector);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteVectorDefaultEmpty()
	{
		FVector Empty;
		return Empty.Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads the up vector
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleVectorsCopyIndependence()
	{
		FVector OutA;
		FVector OutB;
		WriteMultipleVectors(OutA, OutB);
		OutA.X = 0.0;
		return OutB.Equals(FVector::UpVector);
	}
}
