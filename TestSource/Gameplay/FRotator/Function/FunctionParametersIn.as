/**
 * A FRotator passed by read-only reference, where the callee reads through the caller's
 * value without taking a copy. C++ executes the entrypoint and checks the value it
 * produces, so the name is part of the contract and is kept verbatim. The observers cover
 * the empty argument and the independence of the caller's rotator.
 *
 * @Theme Gameplay.FRotator
 * @Subject FRotator.FunctionParametersIn
 * @Harness Function
 * @Tag Gameplay.FRotator.FunctionParametersIn
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive &in parameter oracle.
 * @Provenance C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersIn
 * @Provenance Oracle: AcceptRotatorIn(0,90,0) Equals native Vector().
 * @Provenance Extra: default Zero Vector is Forward. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Convert a rotator passed by read-only reference into its forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a rotator
	 * @Return the rotator's Vector()
	 * @Param r the rotator to convert
	 */
	UFUNCTION()
	FVector AcceptRotatorIn(FRotator&in r)
	{
		return r.Vector();
	}

	/**
	 * Observe that a yaw-90 rotator converts to the same vector as the native helper.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the result equals FRotator(0, 90, 0).Vector()
	 */
	UFUNCTION()
	bool AcceptRotatorInNominal()
	{
		FRotator Input = FRotator(0, 90, 0);
		return AcceptRotatorIn(Input).Equals(FRotator(0, 90, 0).Vector(), 0.001);
	}

	/**
	 * Observe that an empty rotator converts to the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a default-constructed rotator
	 * @Return true when the result equals the forward vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptRotatorInDefaultEmpty()
	{
		FRotator Empty = FRotator();
		return AcceptRotatorIn(Empty).Equals(FVector::ForwardVector, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's rotator alone.
	 *
	 * @Kind Observe
	 * @Covers FRotator.FunctionParametersIn
	 * @Inputs a rotator read through the reference
	 * @Return true when the argument still reads FRotator(0, 90, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptRotatorInCopyIndependence()
	{
		FRotator Input = FRotator(0, 90, 0);
		FVector Result = AcceptRotatorIn(Input);
		Result.X = 0.0;
		return Input == FRotator(0, 90, 0);
	}
}
