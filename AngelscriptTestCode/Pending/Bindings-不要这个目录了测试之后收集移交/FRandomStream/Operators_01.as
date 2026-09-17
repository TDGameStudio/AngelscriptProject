/**
 * @version v1
 * @summary Observe FRandomStream string concatenation that returns a new string.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRandomStream string concatenation that returns a new string.
 * @topic Baseline
 */
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
/** @end */
