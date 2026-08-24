// Purpose: Observe remaining FQuat4f direction queries, twist angle, and
// FindBetween factories.
// AS-facing API: FVector3f FQuat4f.GetRightVector() const;
// FVector3f FQuat4f.GetUpVector() const; FVector3f FQuat4f.GetRotationAxis() const;
// float32 FQuat4f.GetTwistAngle(const FVector3f& InTwistAxis) const;
// FQuat4f FQuat4f::FindBetween(const FVector3f& Vector1, const FVector3f& Vector2);
// FQuat4f FQuat4f::FindBetweenVectors(const FVector3f& Vector1, const FVector3f& Vector2);
// FQuat4f FQuat4f::FindBetweenNormals(const FVector3f& Normal1, const FVector3f& Normal2);
// Inputs: Identity, yaw 90, UpVector as the twist axis, Forward and Right.
// Expected observations: Identity Right is +Y and Up is +Z. Yaw 90 rotation
// axis leans on +Z. Twist around Up is 0 for Identity and ~HALF_PI for yaw.
// FindBetween(Forward, Right) rotates Forward toward +Y.
// Boundary/ownership: Factories return new quaternions. Axis helpers return
// new vectors.

namespace TS_FQuat4f_Queries_02
{
	bool Observe_GetRightVector_Nominal()
	{
		FVector3f Right = FQuat4f::Identity.GetRightVector();
		return Right.Y == 1.0 && Right.X == 0.0;
	}

	bool Observe_GetUpVector_Nominal()
	{
		FVector3f Up = FQuat4f::Identity.GetUpVector();
		return Up.Z == 1.0 && Up.X == 0.0;
	}

	bool Observe_GetRotationAxis_Nominal()
	{
		FVector3f IdentityAxis = FQuat4f::Identity.GetRotationAxis();
		FVector3f YawAxis = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetRotationAxis();
		return IdentityAxis.Size() > 0.0 && YawAxis.Z > 0.9;
	}

	bool Observe_GetTwistAngle_Nominal()
	{
		float32 IdentityTwist = FQuat4f::Identity.GetTwistAngle(FVector3f::UpVector);
		float32 YawTwist = FQuat4f(FRotator3f(0.0, 90.0, 0.0)).GetTwistAngle(FVector3f::UpVector);
		return IdentityTwist == 0.0 && YawTwist > 1.0;
	}

	bool Observe_FindBetween_Nominal()
	{
		FQuat4f Same = FQuat4f::FindBetween(FVector3f::ForwardVector, FVector3f::ForwardVector);
		FQuat4f Turn = FQuat4f::FindBetween(FVector3f::ForwardVector, FVector3f::RightVector);
		FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
		return Same.IsIdentity() && Rotated.Y > 0.9;
	}

	bool Observe_FindBetweenVectors_Nominal()
	{
		FQuat4f Turn = FQuat4f::FindBetweenVectors(FVector3f::ForwardVector, FVector3f::RightVector);
		FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
		return Rotated.Y > 0.9 && Rotated.X < 0.1;
	}

	bool Observe_FindBetweenNormals_Nominal()
	{
		FQuat4f Turn = FQuat4f::FindBetweenNormals(FVector3f::ForwardVector, FVector3f::RightVector);
		FVector3f Rotated = Turn.RotateVector(FVector3f::ForwardVector);
		return Rotated.Y > 0.9;
	}
}
