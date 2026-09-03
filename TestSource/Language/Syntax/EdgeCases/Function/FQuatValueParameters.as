/**
 * FQuat parameters passed by value. The helpers invert and multiply quaternions
 * received by copy, so the observers confirm the results and that the caller's
 * inputs are untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatValueParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FQuatValueParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersValue
 * @Provenance sha256=5d6e10316313aeb3c5ae53c6f52b1910070cd98e540b7f6e7e3617a220490fb6; lines 51-61.
 * @Provenance Oracle: AcceptQuat(yaw 90) equals Inverse; AcceptTwoQuats(45,45) equals a*b.
 * @Provenance Extra: Identity inverse is Identity; value args are copy-independent. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Inverts a quaternion received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming quaternion
	 * @Return the inverse of the input
	 * @Param q the incoming quaternion
	 */
	FQuat AcceptQuat(FQuat q)
	{
		return q.Inverse();
	}

	/**
	 * Multiplies two quaternions received by value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming quaternions
	 * @Return the product of both inputs
	 * @Param a the left factor
	 * @Param b the right factor
	 */
	FQuat AcceptTwoQuats(FQuat a, FQuat b)
	{
		return a * b;
	}

	/**
	 * Observe that inversion and multiplication work on the copies.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion and two yaw-45 quaternions
	 * @Return true when the inverse and product match
	 */
	UFUNCTION()
	bool FQuatValueNominal()
	{
		FQuat Input = FQuat(FRotator(0, 90, 0));
		FQuat A = FQuat(FRotator(0, 45, 0));
		FQuat B = FQuat(FRotator(0, 45, 0));

		if (!AcceptQuat(Input).Equals(Input.Inverse(), 0.01))
		{
			return false;
		}

		return AcceptTwoQuats(A, B).Equals(A * B, 0.01);
	}

	/**
	 * Observe that the identity's inverse is the identity.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs FQuat::Identity passed to both helpers
	 * @Return true when both results are the identity
	 * @Boundary identity input
	 */
	UFUNCTION()
	bool FQuatValueIdentityEmpty()
	{
		if (!AcceptQuat(FQuat::Identity).IsIdentity(0.001))
		{
			return false;
		}

		return AcceptTwoQuats(FQuat::Identity, FQuat::Identity).IsIdentity(0.001);
	}

	/**
	 * Observe that the caller's input survives the call unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion passed by value
	 * @Return true when the input is unchanged and the result is its inverse
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FQuatValueCopyIndependence()
	{
		FQuat Input = FQuat(FRotator(0, 90, 0));
		FQuat Before = Input;
		FQuat Result = AcceptQuat(Input);

		if (!Input.Equals(Before, 0.001))
		{
			return false;
		}

		return Result.Equals(Before.Inverse(), 0.01);
	}
}
