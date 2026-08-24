// Purpose: Observe FQuat4f assignment plus add/subtract/multiply compound
// and value-returning arithmetic, including vector rotation.
// AS-facing API: FQuat4f Quat = Other; FQuat4f Result = Quat + Other;
// FQuat4f Result = Quat - Other; Quat += Other; Quat -= Other;
// FQuat4f Result = Quat * Other; FQuat4f Result = Quat * Scale;
// FVector3f Result = Quat * Other; Quat *= Other; Quat *= Scale;
// Inputs: Identity, (0,0,0,2), Scale 2.0, ForwardVector, yaw 90, and a saved
// original for independence.
// Expected observations: Assignment copies W. Identity + Identity has W=2.
// += mutates in place. Identity * Identity remains identity. * 2 doubles W.
// Identity * Forward stays Forward. Yaw 90 * Forward leans on +Y.
// Boundary/ownership: Compound operators mutate Quat. Value-returning
// operators return a new quaternion or vector.

namespace TS_FQuat4f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FQuat4f Left = FQuat4f::Identity;
		FQuat4f Right(0.0, 0.0, 0.0, 2.0);
		FQuat4f Original = Left;
		Left = Right;
		FQuat4f Sum = FQuat4f::Identity + FQuat4f::Identity;
		return Left.W == 2.0 && Original.W == 1.0 && Sum.W == 2.0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FQuat4f Quat = FQuat4f::Identity;
		Quat += FQuat4f::Identity;
		return Quat.W == 2.0 && FQuat4f::Identity.W == 1.0;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FQuat4f Quat(0.0, 0.0, 0.0, 2.0);
		FQuat4f Difference = Quat - FQuat4f::Identity;
		Quat -= FQuat4f::Identity;
		return Difference.W == 1.0 && Quat.W == 1.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FQuat4f Product = FQuat4f::Identity * FQuat4f::Identity;
		FQuat4f Composed = FQuat4f::Identity;
		Composed *= FQuat4f::Identity;
		FQuat4f Scaled = FQuat4f::Identity * 2.0;
		FQuat4f ScaledInPlace = FQuat4f::Identity;
		ScaledInPlace *= 2.0;
		FVector3f Forward = FQuat4f::Identity * FVector3f::ForwardVector;
		FQuat4f Yaw(FRotator3f(0.0, 90.0, 0.0));
		FVector3f Turned = Yaw * FVector3f::ForwardVector;
		return Product.W == 1.0 && Composed.W == 1.0 && Scaled.W == 2.0 && ScaledInPlace.W == 2.0 && Forward.X == 1.0 && Turned.Y > 0.9;
	}
}
