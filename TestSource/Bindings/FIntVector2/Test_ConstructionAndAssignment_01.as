// Purpose: Observe FIntVector2 assignment and formatter interpolation.
// AS-facing API: Left = Right; FString Text = f"{Vector}";
// Inputs: (2,4), copy assignment, and zero as the empty state.
// Expected observations: Assignment copies X/Y. f"{Vector}" is non-empty.
// Source remains independent after later mutation of Left.
// Boundary/ownership: Assignment copies the two integer components.

namespace TS_FIntVector2_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FIntVector2 Left(2, 4);
		FIntVector2 Right(5, 6);
		Left = Right;
		Right.X = 0;
		FString Text = f"{Left}";
		return Left.X == 5 && Left.Y == 6 && Text.Len() > 0;
	}
}
