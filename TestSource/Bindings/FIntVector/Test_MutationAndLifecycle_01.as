// Purpose: Observe FString.Append of an FIntVector.
// AS-facing API: Text.Append(Vector);
// Inputs: Seeded "v:", Vector (1,2,3), repeated append, Empty restoration.
// Expected observations: Length grows twice then returns to 0. Vector is
// unchanged.
// Boundary/ownership: Append copies formatted text.

namespace TS_FIntVector_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "v:";
		FIntVector Vector(1, 2, 3);
		int Before = Text.Len();
		Text.Append(Vector);
		int AfterFirst = Text.Len();
		Text.Append(Vector);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.X == 1;
	}
}
