/**
 * @version v1
 * @summary Observe FVector4f value-returning arithmetic, subscript, equality, and string concatenation, including invalid index.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector4f value-returning arithmetic, subscript, equality, and string concatenation, including invalid index.
 * @topic Baseline
 */
// Vector[Index]; Vector == Other; Text + Vector.
// Inputs: (2,4,6,8), Other (1,1,1,1), Scale 2, Divisor 2, index 0/3, written
// Y 9, prefix "v:", invalid index 4.
// Expected observations: + is (3,5,7,9). * 2 doubles W to 16. [0] is X and
// [3] is W. Writing [1] mutates Y. Copies compare true. Text + Vector is
// longer than the prefix.
// Boundary/ownership: Value-returning operators do not mutate. Index 0..3
// selects XYZW. Out-of-range is the diagnostic path.

namespace TS_FVector4f_Operators_01
{
	// Vector + Other is (3,5,7,9). FString + Vector grows past the "v:" prefix.
	bool Observe_Addition_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Sum = Vector + FVector4f(1.0f, 1.0f, 1.0f, 1.0f);
		FString Combined = FString("v:") + Vector;
		return Sum.X == 3.0f && Sum.W == 9.0f && Combined.Len() > 2 && Vector.W == 8.0f;
	}

	// Vector - Other is (1,3,5,7) and does not mutate Vector.
	bool Observe_Subtraction_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Difference = Vector - FVector4f(1.0f, 1.0f, 1.0f, 1.0f);
		return Difference.X == 1.0f && Difference.W == 7.0f && Vector.W == 8.0f;
	}

	// Vector * 2 doubles W to 16 and does not mutate Vector.
	bool Observe_Surface014_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Scaled = Vector * 2.0f;
		return Scaled.X == 4.0f && Scaled.W == 16.0f && Vector.W == 8.0f;
	}

	// Vector / 2 halves W to 4.
	bool Observe_Surface015_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Quotient = Vector / 2.0f;
		return Quotient.X == 1.0f && Quotient.W == 4.0f;
	}

	// Subscript [0] is X, [3] is W, and writing [1] mutates Y.
	bool Observe_Index_Nominal()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		float32 X = Vector[0];
		float32 W = Vector[3];
		Vector[1] = 9.0f;
		return X == 2.0f && W == 8.0f && Vector.Y == 9.0f;
	}

	// Copies compare true; a different W compares false.
	bool Observe_Equality_Nominal()
	{
		FVector4f Left(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Right(2.0f, 4.0f, 6.0f, 8.0f);
		FVector4f Different(2.0f, 4.0f, 6.0f, 9.0f);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FVector4f Vector(2.0f, 4.0f, 6.0f, 8.0f);
		float32 Invalid = Vector[4];
	}
}
/** @end */
