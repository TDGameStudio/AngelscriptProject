/**
 * FVector2Ds passed by value, where the callee receives its own copy. C++ executes each
 * entrypoint and checks the value it produces, so those names are part of the contract
 * and are kept verbatim. The observers cover the empty argument and the independence of
 * the caller's vector.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.FunctionParametersValue
 * @Harness Function
 * @Tag Gameplay.FVector2D.FunctionParametersValue
 * @Namespace FVector2DTest
 * @Provenance Theme: Gameplay.FVector2D. Positive value-parameter oracles.
 * @Provenance C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersValue
 * @Provenance Oracle: AcceptVector((5,10)) == (10,20); AcceptTwoVectors((0,0),(3,4)) == 5.0.
 * @Provenance Extra: empty ZeroVector *2 stays zero; copy independence of AcceptVector input.
 * @Provenance DefaultSafe.
 */

namespace FVector2DTest
{
	/**
	 * Double every component of a vector passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a vector
	 * @Return the vector with every component doubled
	 * @Param v the vector to scale
	 */
	UFUNCTION()
	FVector2D AcceptVector(FVector2D v)
	{
		return v * 2.0;
	}

	/**
	 * Measure the distance between two vectors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs two vectors
	 * @Return the distance between them
	 * @Param a the first vector
	 * @Param b the second vector
	 */
	UFUNCTION()
	float AcceptTwoVectors(FVector2D a, FVector2D b)
	{
		return a.Distance(b);
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FVector2D(10, 20)
	 */
	UFUNCTION()
	bool AcceptVectorNominal()
	{
		return AcceptVector(FVector2D(5, 10)).Equals(FVector2D(10, 20));
	}

	/**
	 * Observe that the distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the distance is 5
	 */
	UFUNCTION()
	bool AcceptTwoVectorsNominal()
	{
		return Math::IsNearlyEqual(AcceptTwoVectors(FVector2D(0, 0), FVector2D(3, 4)), 5.0, 0.001);
	}

	/**
	 * Observe that doubling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a default-constructed vector
	 * @Return true when the result equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorDefaultEmpty()
	{
		return AcceptVector(FVector2D()).Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating the returned vector leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a vector and the mutated result of passing it in
	 * @Return true when the argument still reads FVector2D(5, 10)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorCopyIndependence()
	{
		FVector2D Input = FVector2D(5, 10);
		FVector2D Result = AcceptVector(Input);
		Result.X = 0.0;
		return Input.Equals(FVector2D(5, 10));
	}
}
