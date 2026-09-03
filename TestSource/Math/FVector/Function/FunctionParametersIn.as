/**
 * A FVector passed by read-only reference, where the callee reads through the caller's
 * value without taking a copy. C++ executes the entrypoint and checks the value it
 * produces, so the name is part of the contract and is kept verbatim. The observers cover
 * the empty argument and the independence of the caller's vector.
 *
 * @Theme Math.FVector
 * @Subject FVector.FunctionParametersIn
 * @Harness Function
 * @Tag Math.FVector.FunctionParametersIn
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive &in Size() oracle.
 * @Provenance C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersIn
 * @Provenance Oracle: AcceptVectorIn((3,4,0)) == 5.0. Extra: empty ZeroVector Size 0;
 * @Provenance copy independence of the &in argument. DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Measure the length of a vector passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a vector
	 * @Return the length of the vector
	 * @Param v the vector to measure
	 */
	UFUNCTION()
	float AcceptVectorIn(FVector&in v)
	{
		return v.Size();
	}

	/**
	 * Observe that the measured length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the length is 5
	 */
	UFUNCTION()
	bool AcceptVectorInNominal()
	{
		FVector Input = FVector(3, 4, 0);
		return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a default-constructed vector
	 * @Return true when the length is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorInDefaultEmpty()
	{
		FVector Empty = FVector();
		return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a vector read through the reference
	 * @Return true when the argument still reads FVector(3, 4, 0) and the size is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorInCopyIndependence()
	{
		FVector Input = FVector(3, 4, 0);
		float Size = AcceptVectorIn(Input);

		if (!Input.Equals(FVector(3, 4, 0)))
		{
			return false;
		}
		return Math::IsNearlyEqual(Size, 5.0, 0.001);
	}
}
