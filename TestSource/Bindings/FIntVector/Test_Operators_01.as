// Purpose: Observe FIntVector value-returning arithmetic, subscript, equality,
// and string concatenation.
// AS-facing API: Vector + Other; Vector - Other; Vector * Scale; Vector / Divisor;
// Vector[Index]; Vector == Other; Text + Vector;
// Inputs: (2,4,6), Other (1,1,1), Scale 2, Divisor 2, index 0/2, prefix "v:".
// Expected observations: + is (3,5,7). [0] is X. Equality is true for copies.
// Text + Vector is longer than the prefix.
// Boundary/ownership: / uses integer division. Invalid index is diagnostic.

namespace TS_FIntVector_Operators_01
{
	// Vector + Other is (3,5,7). FString + Vector is longer than "v:". Source unchanged.
	bool Observe_Addition_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		FIntVector Sum = Vector + FIntVector(1, 1, 1);
		FString Combined = FString("v:") + Vector;
		return Sum.X == 3 && Sum.Z == 7 && Combined.Len() > 2 && Vector.X == 2;
	}

	// Vector - Other is (1,3,5). Value-returning subtraction.
	bool Observe_Subtraction_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		FIntVector Difference = Vector - FIntVector(1, 1, 1);
		return Difference.X == 1 && Difference.Z == 5;
	}

	// Vector * 2 is (4,8,12). Value-returning scale.
	bool Observe_Surface013_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		FIntVector Scaled = Vector * 2;
		return Scaled.X == 4 && Scaled.Z == 12;
	}

	// Vector / 2 is (1,2,3) with integer division.
	bool Observe_Surface014_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		FIntVector Quotient = Vector / 2;
		return Quotient.Y == 2 && Quotient.Z == 3;
	}

	// Vector[0] is X and Vector[2] is Z. Subscript query.
	bool Observe_Index_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		return Vector[0] == 2 && Vector[2] == 6;
	}

	// Copies compare true; differing Z compares false. Exact equality.
	bool Observe_Equality_Nominal()
	{
		FIntVector Left(2, 4, 6);
		FIntVector Right(2, 4, 6);
		FIntVector Different(2, 4, 7);
		return (Left == Right) && !(Left == Different);
	}

	void ExerciseExpectedFailure()
	{
		FIntVector Vector(2, 4, 6);
		int32 Invalid = Vector[3];
	}
}
