// Purpose: Observe FVector3f subscript aliasing and equality, including
// invalid index.
// AS-facing API: float32& Component = Vector[Index]; float32 Component = Vector[Index];
// bool bEqual = Left == Right.
// Inputs: (2,4,6), index 0/2, written Y 9, identical copy, different Z,
// invalid index 3.
// Expected observations: [0] is X, [2] is Z. Writing [1] mutates Y through
// the returned reference. Copies compare true.
// Boundary/ownership: Index 0..2 selects XYZ. Out-of-range is the diagnostic
// path.

namespace TS_FVector3f_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		float32 X = Vector[0];
		float32 Z = Vector[2];
		Vector[1] = 9.0f;
		return X == 2.0f && Z == 6.0f && Vector.Y == 9.0f;
	}

	bool Observe_Equality_Nominal()
	{
		FVector3f Left(2.0f, 4.0f, 6.0f);
		FVector3f Right(2.0f, 4.0f, 6.0f);
		FVector3f Different(2.0f, 4.0f, 7.0f);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FVector3f Vector(2.0f, 4.0f, 6.0f);
		float32 Invalid = Vector[3];
	}
}
