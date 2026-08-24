// Purpose: Observe in-place quaternion divide, quaternion-vector multiply,
// and formatter interpolation.
// AS-facing API: Quat /= Scale; FVector Result = Quat * Other;
// FString Text = f"{Quat}";
// Inputs: (0,0,0,2) divided by 2, Identity * ForwardVector, yaw-90 * Forward,
// and Identity as the formatter source.
// Expected observations: /= 2 restores W=1. Identity leaves Forward unchanged.
// Yaw 90 sends Forward toward +Y. f"{Quat}" is non-empty.
// Boundary/ownership: /= mutates Quat. Vector multiply returns a new FVector.
// The formatter copies text; the quaternion is unchanged.

namespace TS_FQuat_ConstructionAndAssignment_02
{
	bool Observe_DivideAssign_Nominal()
	{
		FQuat Quat(0.0, 0.0, 0.0, 2.0);
		Quat /= 2.0;
		return Quat.W == 1.0 && Quat.X == 0.0;
	}

	bool Observe_Assignment_Nominal()
	{
		FVector Forward = FQuat::Identity * FVector::ForwardVector;
		FQuat Yaw(FRotator(0, 90, 0));
		FVector Turned = Yaw * FVector::ForwardVector;
		FString Text = f"{FQuat::Identity}";
		return Forward.X == 1.0 && Turned.Y > 0.9 && Text.Len() > 0;
	}
}
