/**
 * @version v1
 * @summary Observe remaining FQuat axis/direction queries and twist angle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FQuat axis/direction queries and twist angle.
 * @topic Baseline
 */
// FVector Quat.GetForwardVector() const; FVector Quat.GetRightVector() const;
// FVector Quat.GetUpVector() const; FVector Quat.GetRotationAxis() const;
// float64 Quat.GetTwistAngle(const FVector& InTwistAxis) const;
// Inputs: Identity, yaw 90, UpVector as the twist axis, and Forward as a
// zero-twist axis for yaw.
// Expected observations: Identity Y is +Y, Z is +Z. Forward/Right/Up match
// those axes. Yaw 90 rotation axis leans on +Z. Twist around Up is ~HALF_PI
// for yaw 90 and 0 for Identity.
// Boundary/ownership: Axis helpers return new vectors. GetTwistAngle is
// signed radians around InTwistAxis.

namespace TS_FQuat_Queries_02
{
	bool Observe_GetAxisY_Nominal()
	{
		FVector IdentityY = FQuat::Identity.GetAxisY();
		return IdentityY.Y == 1.0 && IdentityY.X == 0.0;
	}

	bool Observe_GetAxisZ_Nominal()
	{
		FVector IdentityZ = FQuat::Identity.GetAxisZ();
		return IdentityZ.Z == 1.0 && IdentityZ.X == 0.0;
	}

	bool Observe_GetForwardVector_Nominal()
	{
		FVector Forward = FQuat::Identity.GetForwardVector();
		FVector YawForward = FQuat(FRotator(0, 90, 0)).GetForwardVector();
		return Forward.X == 1.0 && YawForward.Y > 0.9;
	}

	bool Observe_GetRightVector_Nominal()
	{
		FVector Right = FQuat::Identity.GetRightVector();
		return Right.Y == 1.0 && Right.X == 0.0;
	}

	bool Observe_GetUpVector_Nominal()
	{
		FVector Up = FQuat::Identity.GetUpVector();
		return Up.Z == 1.0 && Up.X == 0.0;
	}

	bool Observe_GetRotationAxis_Nominal()
	{
		FVector IdentityAxis = FQuat::Identity.GetRotationAxis();
		FVector YawAxis = FQuat(FRotator(0, 90, 0)).GetRotationAxis();
		return IdentityAxis.Size() > 0.0 && YawAxis.Z > 0.9;
	}

	bool Observe_GetTwistAngle_Nominal()
	{
		float64 IdentityTwist = FQuat::Identity.GetTwistAngle(FVector::UpVector);
		float64 YawTwist = FQuat(FRotator(0, 90, 0)).GetTwistAngle(FVector::UpVector);
		return IdentityTwist == 0.0 && YawTwist > 1.0;
	}
}
/** @end */
