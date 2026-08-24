// Purpose: Observe value-returning FRotator arithmetic, exact equality, and
// string concatenation.
// AS-facing API: Rotator + Other; Rotator - Other; Rotator * Scale;
// Rotator == Other; Text + Rotator;
// Inputs: (10,20,30), Other (1,2,3), Scale 2, ZeroRotator, and text "rot:".
// Expected observations: + is (11,22,33). - is (9,18,27). * 2 is (20,40,60).
// Identical copies compare true. Zero addition is stable. Text + Rotator is
// longer than the prefix. Left operands are unchanged.
// Boundary/ownership: These operators return new values. They do not mutate
// Rotator.

namespace TS_FRotator_Operators_01
{
	// FRotator + FRotator. Inputs (10,20,30) and (1,2,3). Sum is (11,22,33);
	// adding ZeroRotator is stable. Value-returning; left rotator unchanged.
	bool Observe_Addition_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FRotator Other(1.0, 2.0, 3.0);
		FRotator Sum = Rotator + Other;
		FRotator WithZero = Rotator + FRotator::ZeroRotator;
		return Sum.Pitch == 11.0 && Sum.Yaw == 22.0 && Sum.Roll == 33.0 && WithZero.Pitch == 10.0 && Rotator.Pitch == 10.0;
	}

	// FRotator - FRotator. Inputs (10,20,30) and (1,2,3). Difference is
	// (9,18,27). Value-returning; left rotator unchanged.
	bool Observe_Subtraction_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FRotator Difference = Rotator - FRotator(1.0, 2.0, 3.0);
		return Difference.Pitch == 9.0 && Difference.Yaw == 18.0 && Difference.Roll == 27.0 && Rotator.Yaw == 20.0;
	}

	// FRotator * Scale and FString + FRotator. Inputs (10,20,30), Scale 2.0,
	// and prefix "rot:". Scaled is (20,40,60); concat length exceeds 4.
	// Value-returning; rotator unchanged.
	bool Observe_Surface016_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FRotator Scaled = Rotator * 2.0;
		FString Text = "rot:" + Rotator;
		return Scaled.Pitch == 20.0 && Scaled.Yaw == 40.0 && Scaled.Roll == 60.0 && Text.Len() > 4 && Rotator.Roll == 30.0;
	}

	// FRotator equality. Inputs identical (10,20,30) copies and a 21 yaw.
	// Identical copies are true; different yaw is false. Exact degrees.
	bool Observe_Equality_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FRotator Same(10.0, 20.0, 30.0);
		FRotator Different(10.0, 21.0, 30.0);
		return (Rotator == Same) && !(Rotator == Different);
	}
}
