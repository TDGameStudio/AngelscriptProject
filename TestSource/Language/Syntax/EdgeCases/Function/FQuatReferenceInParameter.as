/**
 * An FQuat passed by reference, whose local X axis is extracted. The observers
 * confirm the axis for a yawed and for the identity quaternion, and that the
 * caller's input is untouched.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatReferenceInParameter
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FQuatReferenceInParameter
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersIn
 * @Provenance sha256=cc2c557820a8df136bc294d5f7d1e98590ff94f31fd55272b609add23a9018fc; lines 99-104.
 * @Provenance Oracle: AcceptQuatIn(yaw 90) equals GetAxisX of that quat. Extra: Identity axis is Forward.
 * @Provenance DefaultSafe. &in does not mutate the caller.
 */

namespace SyntaxTest
{
	/**
	 * Extracts the local X axis of a quaternion received by reference.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the incoming quaternion reference
	 * @Return the quaternion's X axis
	 * @Param q the read-only reference
	 */
	FVector AcceptQuatIn(FQuat&in q)
	{
		return q.GetAxisX();
	}

	/**
	 * Observe the X axis of a yaw-90 quaternion.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion
	 * @Return true when the axis matches GetAxisX of the input
	 */
	UFUNCTION()
	bool FQuatInNominal()
	{
		FQuat Input = FQuat(FRotator(0, 90, 0));
		return AcceptQuatIn(Input).Equals(Input.GetAxisX(), 0.01);
	}

	/**
	 * Observe the X axis of the identity quaternion.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs FQuat::Identity
	 * @Return true when the axis is the forward vector
	 * @Boundary identity input
	 */
	UFUNCTION()
	bool FQuatInIdentityEmpty()
	{
		FQuat Identity = FQuat::Identity;
		return AcceptQuatIn(Identity).Equals(FVector::ForwardVector, 0.01);
	}

	/**
	 * Observe that the caller's quaternion survives the call unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion passed by reference
	 * @Return true when the input is unchanged and the axis is correct
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FQuatInCopyIndependence()
	{
		FQuat Input = FQuat(FRotator(0, 90, 0));
		FQuat Before = Input;
		FVector Axis = AcceptQuatIn(Input);

		if (!Input.Equals(Before, 0.001))
		{
			return false;
		}

		return Axis.Equals(Before.GetAxisX(), 0.01);
	}
}
