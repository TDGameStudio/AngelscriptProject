/**
 * @version v1
 * @summary Observe FRandomStream constructors, Initialize overloads, GenerateNewSeed, RandRange, and VRand, with inverted integer range as the diagnostic companion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FRandomStream constructors, Initialize overloads, GenerateNewSeed, RandRange, and VRand, with inverted integer range as the diagnostic companion.
 * @topic Baseline
 */
// FRandomStream Stream(uint32 InSeed); void FRandomStream.Initialize(int32 InSeed);
// void FRandomStream.Initialize(uint32 InSeed); void FRandomStream.Initialize(FName InName);
// void FRandomStream.GenerateNewSeed();
// int32 FRandomStream.RandRange(int32 Min, int32 Max) const;
// float64 FRandomStream.RandRange(float64 Min, float64 Max) const;
// FVector FRandomStream.VRand() const;
// Inputs: Default stream, signed seed 123, unsigned seed 123, name n"SeedName",
// RandRange (1,1) and (1,1000), float range 0..10, two same-seed streams, and
// inverted (1,0) on the failure path.
// Expected observations: Signed and unsigned 123 share initial seed 123. Name
// initialize is deterministic across two streams. RandRange(1,1) is 1.
// Inclusive (1,1000) stays in range. Float range stays in 0..10. VRand size
// is near 1. Same seeds match the first draw.
// Boundary/ownership: Initialize and GenerateNewSeed replace the initial
// seed. Inverted integer RandRange is the diagnostic companion.

namespace TS_FRandomStream_Behavior_01
{
	bool Observe_Stream_Nominal()
	{
		FRandomStream DefaultStream;
		FRandomStream SignedStream(123);
		uint32 UnsignedSeed = 123;
		FRandomStream UnsignedStream(UnsignedSeed);
		return DefaultStream.GetInitialSeed() == 0 && SignedStream.GetInitialSeed() == 123 && UnsignedStream.GetInitialSeed() == 123;
	}

	bool Observe_Initialize_Nominal()
	{
		FRandomStream Stream;
		Stream.Initialize(123);
		uint32 UnsignedSeed = 123;
		FRandomStream UnsignedStream;
		UnsignedStream.Initialize(UnsignedSeed);
		FRandomStream Named;
		Named.Initialize(n"SeedName");
		FRandomStream NamedTwin;
		NamedTwin.Initialize(n"SeedName");
		return Stream.GetInitialSeed() == 123 && UnsignedStream.GetInitialSeed() == 123 && Named.GetUnsignedInt() == NamedTwin.GetUnsignedInt();
	}

	bool Observe_GenerateNewSeed_Nominal()
	{
		FRandomStream Stream(123);
		int Before = Stream.GetInitialSeed();
		Stream.GenerateNewSeed();
		int After = Stream.GetInitialSeed();
		FRandomStream Control(123);
		uint32 Draw = Stream.GetUnsignedInt();
		uint32 ControlDraw = Control.GetUnsignedInt();
		return After != Before && Draw != ControlDraw;
	}

	bool Observe_RandRange_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		int32 Point = Stream.RandRange(1, 1);
		int32 TwinPoint = Twin.RandRange(1, 1);
		int32 Span = Stream.RandRange(1, 1000);
		float64 FloatSpan = Stream.RandRange(0.0, 10.0);
		return Point == 1 && TwinPoint == 1 && Span >= 1 && Span <= 1000 && FloatSpan >= 0.0 && FloatSpan <= 10.0;
	}

	bool Observe_VRand_Nominal()
	{
		FRandomStream Stream(123);
		FRandomStream Twin(123);
		FVector Unit = Stream.VRand();
		FVector TwinUnit = Twin.VRand();
		return Unit.Size() > 0.9 && Unit.Size() < 1.1 && TwinUnit.X == Unit.X;
	}

	void ExerciseExpectedFailure()
	{
		FRandomStream Stream(123);
		int32 Invalid = Stream.RandRange(1, 0);
	}
}
/** @end */
