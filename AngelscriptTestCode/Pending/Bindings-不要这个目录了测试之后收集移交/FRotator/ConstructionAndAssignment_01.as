/**
 * @version v1
 * @summary Observe FRotator declaration, assignment, in-place arithmetic, and string append-assign.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRotator declaration, assignment, in-place arithmetic, and string append-assign.
 * @topic Baseline
 */
// Rotator -= Other; Rotator *= Scale; Text += Rotator;
// Inputs: Default Rotator, Other (10,20,30), Scale 2, copied original, and
// seeded text "rot:".
// Expected observations: Default is zero. Assignment copies Pitch/Yaw/Roll.
// += adds degrees. -= subtracts. *= 2 doubles components. Text += grows
// length. The copied original stays (10,20,30).
// Boundary/ownership: Compound operators mutate the left rotator. Text +=
// appends ToString text without mutating the rotator.

namespace TS_FRotator_ConstructionAndAssignment_01
{
	// Default FRotator is the zero rotator. Oracle: Pitch/Yaw/Roll == 0. Value construction.
	bool Observe_Surface001_Nominal()
	{
		FRotator Rotator;
		return Rotator.Pitch == 0.0 && Rotator.Yaw == 0.0 && Rotator.Roll == 0.0;
	}

	// Assignment copies components independently; Text += Rotator grows the prefix. Mutates left rotator and string.
	bool Observe_Assignment_Nominal()
	{
		FRotator Rotator;
		FRotator Other(10.0, 20.0, 30.0);
		FRotator Original = Other;
		Rotator = Other;
		bool bCopied = Rotator.Pitch == 10.0 && Rotator.Yaw == 20.0 && Rotator.Roll == 30.0;
		Other.Yaw = 90.0;
		bool bIndependent = Original.Yaw == 20.0 && Rotator.Yaw == 20.0;
		FString Text = "rot:";
		int Before = Text.Len();
		Text += Rotator;
		return bCopied && bIndependent && Text.Len() > Before;
	}

	// += adds degree components in place. Inputs: (10,20,30) += (1,2,3). Mutates the left rotator.
	bool Observe_AddAssign_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FRotator Other(1.0, 2.0, 3.0);
		Rotator += Other;
		return Rotator.Pitch == 11.0 && Rotator.Yaw == 22.0 && Rotator.Roll == 33.0 && Other.Pitch == 1.0;
	}

	// -= subtracts degree components in place. Inputs: (10,20,30) -= (1,2,3). Mutates the left rotator.
	bool Observe_SubtractAssign_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		Rotator -= FRotator(1.0, 2.0, 3.0);
		return Rotator.Pitch == 9.0 && Rotator.Yaw == 18.0 && Rotator.Roll == 27.0;
	}

	// *= scales degree components in place. Inputs: (10,20,30) *= 2. Mutates the left rotator.
	bool Observe_MultiplyAssign_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		Rotator *= 2.0;
		return Rotator.Pitch == 20.0 && Rotator.Yaw == 40.0 && Rotator.Roll == 60.0;
	}
}
/** @end */
