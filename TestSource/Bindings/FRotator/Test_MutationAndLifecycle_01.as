// Purpose: Observe FString.Append of an FRotator, including repeated append
// and Empty restoration.
// AS-facing API: Text.Append(Rotator);
// Inputs: Seeded "rot:", Rotator (10,20,30), a second append, and Empty().
// Expected observations: First append grows length. Second grows further.
// Empty restores length 0. The rotator is unchanged.
// Boundary/ownership: Append copies formatted rotator text into the string.
// The FRotator value is not mutated.

namespace TS_FRotator_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "rot:";
		FRotator Rotator(10.0, 20.0, 30.0);
		int Before = Text.Len();
		Text.Append(Rotator);
		int AfterFirst = Text.Len();
		Text.Append(Rotator);
		int AfterSecond = Text.Len();
		Text.Empty();
		return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Rotator.Pitch == 10.0;
	}
}
