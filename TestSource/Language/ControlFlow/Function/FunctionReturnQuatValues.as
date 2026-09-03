/**
 * FQuat returns are compared with a tolerance, and two rotations compose by
 * multiplication, so two 45-degree yaws multiply to the same quaternion as one
 * 90-degree yaw. The identity quaternion is the default, and a custom yaw is
 * measurably different from it.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.FunctionReturnQuatValues
 * @Harness Function
 * @Tag Language.ControlFlow.FunctionReturnQuatValues
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageFQuatFunctionTests.cpp::FunctionReturnValues
 * @Provenance sha256=35e7acf576555d2970153dab5977e386e059d6bfe913c2eb2b37df9df5e6979d; lines 211-228.
 * @Provenance Oracle: ReturnIdentity equals FQuat::Identity (0.001);
 * @Provenance ReturnCustomQuat equals FQuat(FRotator(0,90,0)) (0.01);
 * @Provenance ReturnComputedQuat equals two 45-yaw products (0.01).
 * @Provenance Extra: custom yaw is not Identity; two 45-yaw products match 90-yaw.
 */

namespace ControlFlowTest
{
	/**
	 * A function returning the identity quaternion.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs FQuat::Identity
	 * @Return the identity quaternion
	 */
	FQuat IdentityQuatReturn()
	{
		return FQuat::Identity;
	}

	/**
	 * A function returning a quaternion built from a 90-degree yaw.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs FQuat(FRotator(0, 90, 0))
	 * @Return the quaternion for a 90-degree yaw
	 */
	FQuat CustomYawQuatReturn()
	{
		return FQuat(FRotator(0, 90, 0));
	}

	/**
	 * A function returning the product of two 45-degree yaws.
	 *
	 * @Covers ControlFlow.Return
	 * @Inputs Two quaternions of 45-degree yaw multiplied together
	 * @Return the composed quaternion
	 */
	FQuat ComputedYawQuatReturn()
	{
		FQuat a = FQuat(FRotator(0, 45, 0));
		FQuat b = FQuat(FRotator(0, 45, 0));
		return a * b;
	}

	/**
	 * Observe that all three returners deliver their expected quaternions.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare each return against its expected quaternion
	 * @Return true when all three match within their tolerances
	 */
	UFUNCTION()
	bool QuatReturnersDeliverTheirValues()
	{
		FQuat ExpectedCustom = FQuat(FRotator(0, 90, 0));
		FQuat ExpectedComputed = FQuat(FRotator(0, 45, 0)) * FQuat(FRotator(0, 45, 0));
		if (!IdentityQuatReturn().Equals(FQuat::Identity, 0.001))
		{
			return false;
		}
		if (!CustomYawQuatReturn().Equals(ExpectedCustom, 0.01))
		{
			return false;
		}
		return ComputedYawQuatReturn().Equals(ExpectedComputed, 0.01);
	}

	/**
	 * Observe the identity default: the identity return matches the identity,
	 * and a custom yaw does not.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare both returns against the identity quaternion
	 * @Return true when only the identity return matches
	 * @Boundary identity quaternion
	 */
	UFUNCTION()
	bool CustomYawDiffersFromIdentity()
	{
		if (!IdentityQuatReturn().Equals(FQuat::Identity, 0.001))
		{
			return false;
		}
		return !CustomYawQuatReturn().Equals(FQuat::Identity, 0.01);
	}

	/**
	 * Observe the composition boundary: two 45-degree yaws compose to the same
	 * quaternion as one 90-degree yaw.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Compare the composed return against the 90-degree return
	 * @Return true when the two match within tolerance
	 * @Boundary quaternion composition
	 */
	UFUNCTION()
	bool TwoHalfYawsComposeToOneFullYaw()
	{
		return ComputedYawQuatReturn().Equals(CustomYawQuatReturn(), 0.01);
	}
}
