// Purpose: Observe FRandomStream.ToString for seeded and default streams.
// AS-facing API: FString FRandomStream.ToString() const;
// Inputs: Seed 123, a default stream, and a second stream with the same seed.
// Expected observations: ToString is non-empty. Two streams with seed 123
// produce the same text before any draws. The stream is unchanged.
// Boundary/ownership: ToString returns a new FString. It does not advance
// the current seed.

namespace TS_FRandomStream_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		FRandomStream DefaultStream;
		FString Text = Stream.ToString();
		FString TwinText = Twin.ToString();
		FString DefaultText = DefaultStream.ToString();
		return Text.Len() > 0 && Text == TwinText && DefaultText.Len() > 0 && Stream.GetInitialSeed() == 123;
	}
}
