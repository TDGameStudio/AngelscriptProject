// Purpose: Observe FQuat4f axis/angle extraction and swing/twist writebacks.
// AS-facing API: void FQuat4f.ToAxisAndAngle(FVector3f& Axis, float32& Angle) const;
// void FQuat4f.ToSwingTwist(const FVector3f& InTwistAxis, FQuat4f& OutSwing, FQuat4f& OutTwist) const;
// Inputs: Identity and yaw 90, UpVector as the twist axis, and zeroed
// out-parameters before each call.
// Expected observations: Identity angle is 0. Yaw 90 angle is about HALF_PI
// and the axis leans on +Z. Swing around Up for a yaw-only rotation is
// identity-like; twist is not identity.
// Boundary/ownership: Axis/Angle and OutSwing/OutTwist are writebacks. The
// receiver quaternion is not mutated.

namespace TS_FQuat4f_ConversionAndFormatting_01
{
	bool Observe_ToAxisAndAngle_Nominal()
	{
		FVector3f IdentityAxis = FVector3f::ZeroVector;
		float32 IdentityAngle = 1.0;
		FQuat4f::Identity.ToAxisAndAngle(IdentityAxis, IdentityAngle);
		FVector3f YawAxis = FVector3f::ZeroVector;
		float32 YawAngle = 0.0;
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		Yaw.ToAxisAndAngle(YawAxis, YawAngle);
		return IdentityAngle == 0.0 && YawAngle > 1.0 && YawAxis.Z > 0.9;
	}

	bool Observe_ToSwingTwist_Nominal()
	{
		FQuat4f Swing = FQuat4f::Identity;
		FQuat4f Twist = FQuat4f::Identity;
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		Yaw.ToSwingTwist(FVector3f::UpVector, Swing, Twist);
		FQuat4f IdentitySwing(0.0, 0.0, 0.0, 2.0);
		FQuat4f IdentityTwist(0.0, 0.0, 0.0, 2.0);
		FQuat4f::Identity.ToSwingTwist(FVector3f::UpVector, IdentitySwing, IdentityTwist);
		return Swing.IsIdentity() && !Twist.IsIdentity() && IdentitySwing.IsIdentity();
	}
}
