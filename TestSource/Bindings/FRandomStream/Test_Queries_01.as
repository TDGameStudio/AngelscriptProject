// Purpose: Observe FRandomStream seed queries, fraction/unsigned draws, and
// unit-vector sampling, including same-seed determinism.
// AS-facing API: int FRandomStream.GetInitialSeed() const;
// float32 FRandomStream.GetFraction() const;
// uint32 FRandomStream.GetUnsignedInt() const;
// int32 FRandomStream.GetCurrentSeed() const;
// FVector FRandomStream.GetUnitVector() const;
// Inputs: Seed 123 on two streams, a default stream, and a post-draw stream
// for current-seed change.
// Expected observations: GetInitialSeed is 123. Two streams with seed 123
// produce the same first unsigned int. GetFraction is in 0..1. GetUnitVector
// has size near 1. GetCurrentSeed changes after a draw.
// Boundary/ownership: Draw helpers are const but advance the current seed.
// Initial seed is unchanged by draws.

namespace TS_FRandomStream_Queries_01
{
	bool Observe_GetInitialSeed_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		FRandomStream DefaultStream;
		return Stream.GetInitialSeed() == 123 && Twin.GetInitialSeed() == 123 && DefaultStream.GetInitialSeed() == 0;
	}

	bool Observe_GetFraction_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		float32 Fraction = Stream.GetFraction();
		float32 TwinFraction = Twin.GetFraction();
		return Fraction >= 0.0 && Fraction <= 1.0 && TwinFraction == Fraction;
	}

	bool Observe_GetUnsignedInt_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		uint32 First = Stream.GetUnsignedInt();
		uint32 TwinFirst = Twin.GetUnsignedInt();
		uint32 Second = Stream.GetUnsignedInt();
		return First == TwinFirst && Second != First;
	}

	bool Observe_GetCurrentSeed_Nominal()
	{
		FRandomStream Stream(123);
		int32 Before = Stream.GetCurrentSeed();
		Stream.GetUnsignedInt();
		int32 After = Stream.GetCurrentSeed();
		return Before == 123 && After != Before;
	}

	bool Observe_GetUnitVector_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		FVector Unit = Stream.GetUnitVector();
		FVector TwinUnit = Twin.GetUnitVector();
		return Unit.Size() > 0.9 && Unit.Size() < 1.1 && TwinUnit.X == Unit.X;
	}
}
