// Purpose: Observe FRandomStream string concatenation that returns a new
// string.
// AS-facing API: Text + Stream;
// Inputs: Seed 123, prefix "rng:", and an empty prefix as the zero operand.
// Expected observations: Prefix plus stream is longer than the prefix. The
// stream is unchanged. Empty prefix plus stream is still non-empty.
// Boundary/ownership: + returns a new FString. The stream is not mutated by
// formatting.

namespace TS_FRandomStream_Operators_01
{
	bool Observe_Addition_Nominal()
	{
		FRandomStream Stream(123);
		FString Combined = FString("rng:") + Stream;
		FString FromEmpty = FString("") + Stream;
		return Combined.Len() > 4 && FromEmpty.Len() > 0 && Stream.GetInitialSeed() == 123;
	}
}
