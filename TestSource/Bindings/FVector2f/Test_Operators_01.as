// Purpose: Observe FVector2f subscript write/read and equality, including
// invalid index.
// AS-facing API: Vector[Index] = Component; float32 Component = Vector[Index];
// bool bEqual = Vector == Other.
// Inputs: (2,4), index 0/1, written Y 9, identical copy, different Y, invalid
// index 2.
// Expected observations: [0] is X. Writing [1] mutates Y. Copies compare
// true. Different Y compares false.
// Boundary/ownership: Index 0/1 are X/Y. Out-of-range is the diagnostic path.

namespace TS_FVector2f_Operators_01
{
	bool Observe_Index_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		float32 X = Vector[0];
		Vector[1] = 9.0f;
		float32 Y = Vector[1];
		return X == 2.0f && Y == 9.0f && Vector.Y == 9.0f;
	}

	bool Observe_Equality_Nominal()
	{
		FVector2f Left(2.0f, 4.0f);
		FVector2f Right(2.0f, 4.0f);
		FVector2f Different(2.0f, 5.0f);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FVector2f Vector(2.0f, 4.0f);
		float32 Invalid = Vector[2];
	}
}
