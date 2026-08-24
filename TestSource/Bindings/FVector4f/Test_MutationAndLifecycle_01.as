// Purpose: Observe FString.Append of an FVector4f, including repeated append
// and Empty restoration.
// AS-facing API: Text.Append(Vector);
// Inputs: Seeded "v:", Vector (1,2,3,4), repeated append, Empty cleanup.
// Expected observations: First append grows length. Second grows further.
// Empty restores length 0. The vector is unchanged.
// Boundary/ownership: Append copies formatted text. The vector is not mutated.

namespace TS_FVector4f_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "v:";
		FVector4f Vector(1.0f, 2.0f, 3.0f, 4.0f);
		int Before = Text.Len();
		Text.Append(Vector);
		int AfterFirst = Text.Len();
		Text.Append(Vector);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.W == 4.0f;
	}
}
