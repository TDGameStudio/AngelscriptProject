/**
 * @version v1
 * @summary Observe FRandomStream as a value type and in-place string append.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRandomStream as a value type and in-place string append.
 * @topic Baseline
 */
// stream for independence.
// Expected observations: Default construction is a usable value with seed 0.
// Copying preserves the initial seed. Text += Stream grows the prefix.
// Boundary/ownership: += mutates the string. The stream is a value type; the
// append copies formatted text.

namespace TS_FRandomStream_ConstructionAndAssignment_01
{
	// Default FRandomStream is a value with initial seed 0; copy preserves that seed. Value construction.
	bool Observe_Surface001_Nominal()
	{
		FRandomStream Stream;
		FRandomStream Copied = Stream;
		return Stream.GetInitialSeed() == 0 && Copied.GetInitialSeed() == 0;
	}

	// Text += Stream appends formatted stream text. Inputs: prefix "rng:", seed 123. Mutates the string only.
	bool Observe_AddAssign_Nominal()
	{
		FRandomStream Stream(123);
		FString Text = "rng:";
		int Before = Text.Len();
		Text += Stream;
		return Text.Len() > Before && Stream.GetInitialSeed() == 123;
	}
}
/** @end */
