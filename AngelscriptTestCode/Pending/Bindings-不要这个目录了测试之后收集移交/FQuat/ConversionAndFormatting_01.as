/**
 * @version v1
 * @summary Observe FQuat axis/angle extraction and swing/twist writebacks.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FQuat axis/angle extraction and swing/twist writebacks.
 * @topic Baseline
 */
// void Quat.ToAxisAndAngle(FVector& Axis, float64& Angle) const;
// void Quat.ToSwingTwist(const FVector& InTwistAxis, FQuat& OutSwing, FQuat& OutTwist) const;
// Inputs: Identity and yaw 90, float32 and float64 angle outs, UpVector as
// the twist axis, and zeroed out-parameters before each call.
// Expected observations: Identity angle is 0. Yaw 90 angle is about HALF_PI
// and the axis leans on +Z. Swing around Up for a yaw-only rotation is
// identity-like; twist is not identity.
// Boundary/ownership: Axis/Angle and OutSwing/OutTwist are writebacks. The
// receiver quaternion is not mutated.

namespace TS_FQuat_ConversionAndFormatting_01
{
	bool Observe_ToAxisAndAngle_Nominal()
	{
		FVector IdentityAxis = FVector::ZeroVector;
		float32 IdentityAngle32 = 1.0;
		FQuat::Identity.ToAxisAndAngle(IdentityAxis, IdentityAngle32);
		FVector YawAxis = FVector::ZeroVector;
		float64 YawAngle64 = 0.0;
		FQuat Yaw(FRotator(0, 90, 0));
		Yaw.ToAxisAndAngle(YawAxis, YawAngle64);
		FVector YawAxis32 = FVector::ZeroVector;
		float32 YawAngle32 = 0.0;
		Yaw.ToAxisAndAngle(YawAxis32, YawAngle32);
		return IdentityAngle32 == 0.0 && YawAngle64 > 1.0 && YawAxis.Z > 0.9 && YawAngle32 > 1.0;
	}

	bool Observe_ToSwingTwist_Nominal()
	{
		FQuat Swing = FQuat::Identity;
		FQuat Twist = FQuat::Identity;
		FQuat Yaw(FRotator(0, 90, 0));
		Yaw.ToSwingTwist(FVector::UpVector, Swing, Twist);
		FQuat IdentitySwing = FQuat(0.0, 0.0, 0.0, 2.0);
		FQuat IdentityTwist = FQuat(0.0, 0.0, 0.0, 2.0);
		FQuat::Identity.ToSwingTwist(FVector::UpVector, IdentitySwing, IdentityTwist);
		return Swing.IsIdentity() && !Twist.IsIdentity() && IdentitySwing.IsIdentity();
	}
}
/** @end */
