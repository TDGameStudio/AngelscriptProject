// Purpose: Observe FRotator3f assignment, arithmetic, compound operators, and
// formatter interpolation.
// AS-facing API: Left = Right; Sum = Left + Right; Left += Right;
// Difference = Left - Right; Left -= Right; Scaled = Rotator * Scale;
// Rotator *= Scale; FString Text = f"{Rotator}";
// Inputs: (10,20,30), Other (1,2,3), Scale 2, ZeroRotator, and a copied
// original.
// Expected observations: Assignment copies components. + is (11,22,33). +=
// mutates. - / -= subtract. * 2 doubles. f"{Rotator}" is non-empty. Original
// copy stays (10,20,30).
// Boundary/ownership: Value-returning operators do not mutate Left. Compound
// operators mutate the left operand.

namespace TS_FRotator3f_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FRotator3f Left;
		FRotator3f Right(10.0, 20.0, 30.0);
		FRotator3f Original = Right;
		Left = Right;
		FRotator3f Sum = Left + FRotator3f(1.0, 2.0, 3.0);
		Right.Yaw = 90.0;
		FString Text = f"{Left}";
		return Left.Pitch == 10.0 && Left.Yaw == 20.0 && Left.Roll == 30.0 && Sum.Pitch == 11.0 && Original.Yaw == 20.0 && Text.Len() > 0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FRotator3f Left(10.0, 20.0, 30.0);
		FRotator3f Right(1.0, 2.0, 3.0);
		Left += Right;
		return Left.Pitch == 11.0 && Left.Yaw == 22.0 && Left.Roll == 33.0 && Right.Pitch == 1.0;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FRotator3f Left(10.0, 20.0, 30.0);
		FRotator3f Difference = Left - FRotator3f(1.0, 2.0, 3.0);
		Left -= FRotator3f(1.0, 2.0, 3.0);
		return Difference.Pitch == 9.0 && Difference.Yaw == 18.0 && Difference.Roll == 27.0 && Left.Pitch == 9.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FRotator3f Rotator(10.0, 20.0, 30.0);
		FRotator3f Scaled = Rotator * 2.0;
		Rotator *= 2.0;
		return Scaled.Pitch == 20.0 && Scaled.Yaw == 40.0 && Rotator.Roll == 60.0;
	}
}
