// Purpose: Observe FIntVector type, assignment, and compound arithmetic,
// including formatter append.
// AS-facing API: struct FIntVector; Vector = Other; *=; /=; +=; -=; Text += Vector;
// Inputs: (2,4,6), Other (1,1,1), Scale 2, Divisor 2, text "v:".
// Expected observations: Assignment copies components. *= 2 doubles. Integer
// /= 2 halves. += adds. Text += grows.
// Boundary/ownership: Compound operators mutate Vector. Text append copies
// formatted digits.

namespace TS_FIntVector_ConstructionAndAssignment_01
{
	// FIntVector default construction is (0,0,0). Type declaration, no fixture.
	bool Observe_Surface001_Nominal()
	{
		FIntVector Vector;
		return Vector.X == 0 && Vector.Y == 0 && Vector.Z == 0;
	}

	// Vector = Other copies (1,1,1) into (2,4,6). Assignment mutates Left.
	bool Observe_Assignment_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		FIntVector Other(1, 1, 1);
		Vector = Other;
		return Vector.X == 1 && Vector.Z == 1;
	}

	// Vector *= 2 doubles (2,4,6) to (4,8,12). In-place scale.
	bool Observe_MultiplyAssign_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		Vector *= 2;
		return Vector.X == 4 && Vector.Z == 12;
	}

	// Vector /= 2 halves (2,4,6) to (1,2,3) with integer division.
	bool Observe_DivideAssign_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		Vector /= 2;
		return Vector.X == 1 && Vector.Y == 2 && Vector.Z == 3;
	}

	// Vector += (1,1,1) yields (3,5,7). In-place add.
	bool Observe_AddAssign_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		Vector += FIntVector(1, 1, 1);
		return Vector.X == 3 && Vector.Z == 7;
	}

	// Vector -= (1,1,1) yields (1,3,5). Text += Vector grows past prefix "v:".
	bool Observe_SubtractAssign_Nominal()
	{
		FIntVector Vector(2, 4, 6);
		Vector -= FIntVector(1, 1, 1);
		FString Text = "v:";
		Text += Vector;
		return Vector.X == 1 && Text.Len() > 2;
	}
}
