// Purpose: Observe FRotator right and up unit vectors.
// AS-facing API: FVector FRotator.GetRightVector() const;
// FVector FRotator.GetUpVector() const;
// Inputs: ZeroRotator and yaw 90.
// Expected observations: Zero right is RightVector and up is UpVector. Yaw 90
// right points toward -X. Queries do not mutate the rotator.
// Boundary/ownership: Both queries return new unit vectors.

namespace TS_FRotator_Queries_02
{
	bool Observe_GetRightVector_Nominal()
	{
		FRotator Zero;
		FRotator Yaw90(0.0, 90.0, 0.0);
		FVector ZeroRight = Zero.GetRightVector();
		FVector Yaw90Right = Yaw90.GetRightVector();
		return ZeroRight.Equals(FVector::RightVector) && Yaw90Right.Equals(FVector(-1.0, 0.0, 0.0)) && Yaw90.Yaw == 90.0;
	}

	bool Observe_GetUpVector_Nominal()
	{
		FRotator Zero;
		FVector ZeroUp = Zero.GetUpVector();
		FVector Yaw90Up = FRotator(0.0, 90.0, 0.0).GetUpVector();
		return ZeroUp.Equals(FVector::UpVector) && Yaw90Up.Equals(FVector::UpVector);
	}
}
