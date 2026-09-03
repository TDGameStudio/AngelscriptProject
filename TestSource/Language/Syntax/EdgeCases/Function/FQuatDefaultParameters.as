/**
 * An FQuat default argument initialized to the identity. The observers confirm
 * the default applies when omitted, that identity times identity is identity,
 * and that an explicit argument overrides the default.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatDefaultParameters
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.FQuatDefaultParameters
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionDefaultParameters
 * @Provenance sha256=ffe1ddb0e01984bb0a1f5eadded2ca97c47794a209e249815a3ec82c1158783d; lines 269-279.
 * @Provenance Oracle: MultiplyWithDefault(45,45) equals a*b; MultiplyWithImplicitDefault(yaw 90) equals arg.
 * @Provenance Extra: Identity * Identity is Identity. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Multiplies two quaternions, the second defaulting to identity.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required a and an optional b defaulting to identity
	 * @Return the product of both
	 * @Param a the required factor
	 * @Param b the optional factor
	 */
	FQuat MultiplyWithDefault(FQuat a, FQuat b = FQuat::Identity)
	{
		return a * b;
	}

	/**
	 * Calls the multiply helper relying on its identity default.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a required quaternion
	 * @Return the input unchanged, multiplied by identity
	 * @Param a the required factor
	 */
	FQuat MultiplyWithImplicitDefault(FQuat a)
	{
		return MultiplyWithDefault(a);
	}

	/**
	 * Observe the default and the explicit paths agree with direct products.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two yaw-45 quaternions and a yaw-90 quaternion
	 * @Return true when both results match their direct products
	 */
	UFUNCTION()
	bool FQuatDefaultsNominal()
	{
		FQuat Arg1 = FQuat(FRotator(0, 45, 0));
		FQuat Arg2 = FQuat(FRotator(0, 45, 0));
		FQuat Yaw = FQuat(FRotator(0, 90, 0));

		if (!MultiplyWithDefault(Arg1, Arg2).Equals(Arg1 * Arg2, 0.01))
		{
			return false;
		}

		return MultiplyWithImplicitDefault(Yaw).Equals(Yaw, 0.01);
	}

	/**
	 * Observe that identity times the identity default is identity.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs identity through the default-omitting helper
	 * @Return true when the result is identity
	 * @Boundary identity input
	 */
	UFUNCTION()
	bool FQuatDefaultsIdentityEmpty()
	{
		return MultiplyWithImplicitDefault(FQuat::Identity).IsIdentity(0.001);
	}

	/**
	 * Observe that an explicit argument overrides the default.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a yaw-90 quaternion with explicit identity and self arguments
	 * @Return true when identity leaves it unchanged and self does not
	 * @Boundary explicit override
	 */
	UFUNCTION()
	bool FQuatDefaultsExplicitOverrideBoundary()
	{
		FQuat Yaw = FQuat(FRotator(0, 90, 0));

		if (!MultiplyWithDefault(Yaw, FQuat::Identity).Equals(Yaw, 0.01))
		{
			return false;
		}

		return !MultiplyWithDefault(Yaw, Yaw).Equals(Yaw, 0.01);
	}
}
