/**
 * FVectors passed by value, where the callee receives its own copy. C++ executes each
 * entrypoint and checks the value it produces, so those names are part of the contract
 * and are kept verbatim. The observers cover the empty argument and the independence of
 * the caller's vector.
 *
 * @Theme Math.FVector
 * @Subject FVector.FunctionParametersValue
 * @Harness Function
 * @Tag Math.FVector.FunctionParametersValue
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive value-parameter oracles.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersValue
 * @Provenance Oracle: AcceptVector((1,2,3)) == (2,4,6); AcceptTwoVectors((0,0,0),(3,4,0)) == 5.0.
 * @Provenance Extra: empty ZeroVector *2 stays zero; copy independence of AcceptVector input.
 * @Provenance DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Double every component of a vector passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a vector
	 * @Return the vector with every component doubled
	 * @Param v the vector to scale
	 */
	UFUNCTION()
	FVector AcceptVector(FVector v)
	{
		return v * 2.0;
	}

	/**
	 * Measure the distance between two vectors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs two vectors
	 * @Return the distance between them
	 * @Param a the first vector
	 * @Param b the second vector
	 */
	UFUNCTION()
	float AcceptTwoVectors(FVector a, FVector b)
	{
		return a.Distance(b);
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FVector(2, 4, 6)
	 */
	UFUNCTION()
	bool AcceptVectorNominal()
	{
		return AcceptVector(FVector(1, 2, 3)).Equals(FVector(2, 4, 6));
	}

	/**
	 * Observe that the distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the distance is 5
	 */
	UFUNCTION()
	bool AcceptTwoVectorsNominal()
	{
		return Math::IsNearlyEqual(AcceptTwoVectors(FVector(0, 0, 0), FVector(3, 4, 0)), 5.0, 0.001);
	}

	/**
	 * Observe that doubling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a default-constructed vector
	 * @Return true when the result equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorDefaultEmpty()
	{
		return AcceptVector(FVector()).Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating the returned vector leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a vector and the mutated result of passing it in
	 * @Return true when the argument still reads FVector(1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorCopyIndependence()
	{
		FVector Input = FVector(1, 2, 3);
		FVector Result = AcceptVector(Input);
		Result.X = 0.0;
		return Input.Equals(FVector(1, 2, 3));
	}
}
