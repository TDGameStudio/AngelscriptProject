/**
 * FQuat out parameters, including a dual write. The observers confirm the
 * written orientations land and that prior storage is overwritten.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatOutParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FQuatOutParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionParametersOut
 * @Provenance sha256=a695921cf3345581ede198b8b414dd8745ad2a8fbe919dd145b01de23256ef6e; lines 132-143.
 * @Provenance Oracle: WriteQuat yields FQuat(FRotator(0,90,0)); WriteMultipleQuats A=Identity B=pitch 45.
 * @Provenance Extra: &out overwrites prior storage. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Writes a yaw-90 quaternion through an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; the caller's quaternion becomes yaw 90
	 * @Param q the out parameter
	 */
	void WriteQuat(FQuat&out q)
	{
		q = FQuat(FRotator(0, 90, 0));
	}

	/**
	 * Writes two quaternions through out parameters.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two out parameters to write
	 * @Return nothing; a becomes Identity and b becomes pitch 45
	 * @Param a the first out parameter
	 * @Param b the second out parameter
	 */
	void WriteMultipleQuats(FQuat&out a, FQuat&out b)
	{
		a = FQuat::Identity;
		b = FQuat(FRotator(45, 0, 0));
	}

	/**
	 * Observe that both writes land their orientations.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both helpers writing into fresh locals
	 * @Return true when all three quaternions match
	 */
	UFUNCTION()
	bool FQuatOutNominal()
	{
		FQuat Q;
		WriteQuat(Q);
		FQuat A;
		FQuat B;
		WriteMultipleQuats(A, B);

		if (!Q.Equals(FQuat(FRotator(0, 90, 0)), 0.01))
		{
			return false;
		}

		if (!A.Equals(FQuat::Identity, 0.001))
		{
			return false;
		}

		return B.Equals(FQuat(FRotator(45, 0, 0)), 0.01);
	}

	/**
	 * Observe that a write overwrites prior storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteQuat into a local holding Identity
	 * @Return true when the local becomes yaw 90 and is no longer identity
	 * @Boundary overwrite prior
	 */
	UFUNCTION()
	bool FQuatOutOverwritesPrior()
	{
		FQuat Q = FQuat::Identity;
		WriteQuat(Q);

		if (!Q.Equals(FQuat(FRotator(0, 90, 0)), 0.01))
		{
			return false;
		}

		return !Q.IsIdentity(0.001);
	}

	/**
	 * Observe the dual write from swapped starting values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs WriteMultipleQuats into swapped locals
	 * @Return true when a becomes identity and b becomes pitch 45
	 * @Boundary swapped priors
	 */
	UFUNCTION()
	bool FQuatOutMultipleIdentityThenPitch()
	{
		FQuat A = FQuat(FRotator(0, 90, 0));
		FQuat B = FQuat::Identity;
		WriteMultipleQuats(A, B);

		if (!A.IsIdentity(0.001))
		{
			return false;
		}

		return B.Equals(FQuat(FRotator(45, 0, 0)), 0.01);
	}
}
