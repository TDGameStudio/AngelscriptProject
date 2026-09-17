/**
 * @version v1
 * @summary Observe FRandomStream.Reset restoring the initial sequence and FString.Append of a stream.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRandomStream.Reset restoring the initial sequence and FString.Append of a stream.
 * @topic Baseline
 */
// prefix "rng:" with a repeated append.
// Expected observations: After Reset, the next unsigned int matches a fresh
// stream with the same seed. First append grows length; the second grows
// further. The stream initial seed is unchanged.
// Boundary/ownership: Reset is const but restores current seed. Append copies
// formatted text and does not mutate the stream.

namespace TS_FRandomStream_MutationAndLifecycle_01
{
	bool Observe_Reset_Nominal()
	{
		FRandomStream Stream(123);
		Stream.GetUnsignedInt();
		Stream.GetFraction();
		Stream.Reset();
		FRandomStream Fresh(123);
		uint32 AfterReset = Stream.GetUnsignedInt();
		uint32 FreshFirst = Fresh.GetUnsignedInt();
		return AfterReset == FreshFirst && Stream.GetInitialSeed() == 123;
	}

	bool Observe_Append_Nominal()
	{
		FString Text = "rng:";
		FRandomStream Stream(123);
		int Before = Text.Len();
		Text.Append(Stream);
		int AfterFirst = Text.Len();
		Text.Append(Stream);
		int AfterSecond = Text.Len();
		return AfterFirst > Before && AfterSecond > AfterFirst && Stream.GetInitialSeed() == 123;
	}
}
/** @end */
