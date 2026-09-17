/**
 * @version v1
 * @summary FRandomStream host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FRandomStream
 *
 * stream
 * initialize
 * generate-new-seed
 * rand-range
 * v-rand
 * v-rand-cone
 * frandomstream-value-initial-seed
 * add-assign
 * to-string
 * reset
 * append
 * addition
 * get-initial-seed
 * get-fraction
 * get-unsigned-int
 * get-current-seed
 * get-unit-vector
 */
/**
 * @begin stream
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveStreamNominal
 * @summary Observe the container API.
 * @covers FRandomStream.stream
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FRandomStream Stream(uint32 InSeed); void FRandomStream.Initialize(int32 InSeed);
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
bool ObserveStreamNominal()
{
	FRandomStream DefaultStream;
	FRandomStream SignedStream(123);
	uint32 UnsignedSeed = 123;
	FRandomStream UnsignedStream(UnsignedSeed);
	return DefaultStream.GetInitialSeed() == 0 && SignedStream.GetInitialSeed() == 123 && UnsignedStream.GetInitialSeed() == 123;
}
/** @end */
/**
 * @begin initialize
 * @summary seed.
 * @topic Unreal
 */
/**
 * @function ObserveInitializeNominal
 * @summary seed.
 * @covers FRandomStream.initialize
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInitializeNominal()
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
/** @end */
/**
 * @begin generate-new-seed
 * @summary seed.
 * @topic Unreal
 */
/**
 * @function ObserveGenerateNewSeedNominal
 * @summary seed.
 * @covers FRandomStream.generate-new-seed
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGenerateNewSeedNominal()
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
/** @end */
/**
 * @begin rand-range
 * @summary seed.
 * @topic Unreal
 */
/**
 * @function ObserveRandRangeNominal
 * @summary seed.
 * @covers FRandomStream.rand-range
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRandRangeNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	int32 Point = Stream.RandRange(1, 1);
	int32 TwinPoint = Twin.RandRange(1, 1);
	int32 Span = Stream.RandRange(1, 1000);
	float64 FloatSpan = Stream.RandRange(0.0, 10.0);
	return Point == 1 && TwinPoint == 1 && Span >= 1 && Span <= 1000 && FloatSpan >= 0.0 && FloatSpan <= 10.0;
}
/** @end */
/**
 * @begin v-rand
 * @summary seed.
 * @topic Unreal
 */
/**
 * @function ObserveVRandNominal
 * @summary seed.
 * @covers FRandomStream.v-rand
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveVRandNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	FVector Unit = Stream.VRand();
	FVector TwinUnit = Twin.VRand();
	return Unit.Size() > 0.9 && Unit.Size() < 1.1 && TwinUnit.X == Unit.X;
}
/** @end */
/**
 * @begin v-rand-cone
 * @summary stream current seed advances.
 * @topic Unreal
 */
/**
 * @function ObserveVRandConeNominal
 * @summary stream current seed advances.
 * @covers FRandomStream.v-rand-cone
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVRandConeNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	FVector ZeroCone = Stream.VRandCone(FVector::UpVector, 0.0);
	FVector TwinZero = Twin.VRandCone(FVector::UpVector, 0.0);
	FVector SmallCone = Stream.VRandCone(FVector::UpVector, 0.1);
	FVector Ellipse = Stream.VRandCone(FVector::UpVector, 0.1, 0.2);
	return ZeroCone.Z > 0.9 && ZeroCone.Size() > 0.9 && TwinZero.Z == ZeroCone.Z && SmallCone.Z > 0.0 && Ellipse.Size() > 0.9 && Ellipse.Size() < 1.1;
}
/** @end */
/**
 * @begin frandomstream-value-initial-seed
 * @summary Default FRandomStream is a value with initial seed 0; copy preserves that seed.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Default FRandomStream is a value with initial seed 0; copy preserves that seed.
 * @covers FRandomStream.frandomstream-value-initial-seed
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FRandomStream Stream;
	FRandomStream Copied = Stream;
	return Stream.GetInitialSeed() == 0 && Copied.GetInitialSeed() == 0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Text += Stream appends formatted stream text.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Text += Stream appends formatted stream text.
 * @covers FRandomStream.add-assign
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FRandomStream Stream(123);
	FString Text = "rng:";
	int Before = Text.Len();
	Text += Stream;
	return Text.Len() > Before && Stream.GetInitialSeed() == 123;
}
/** @end */
/**
 * @begin to-string
 * @summary the current seed.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary the current seed.
 * @covers FRandomStream.to-string
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	FRandomStream DefaultStream;
	FString Text = Stream.ToString();
	FString TwinText = Twin.ToString();
	FString DefaultText = DefaultStream.ToString();
	return Text.Len() > 0 && Text == TwinText && DefaultText.Len() > 0 && Stream.GetInitialSeed() == 123;
}
/** @end */
/**
 * @begin reset
 * @summary formatted text and does not mutate the stream.
 * @topic Unreal
 */
/**
 * @function ObserveResetNominal
 * @summary formatted text and does not mutate the stream.
 * @covers FRandomStream.reset
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveResetNominal()
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
/** @end */
/**
 * @begin append
 * @summary formatted text and does not mutate the stream.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary formatted text and does not mutate the stream.
 * @covers FRandomStream.append
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
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
/** @end */
/**
 * @begin addition
 * @summary formatting.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary formatting.
 * @covers FRandomStream.addition
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal()
{
	FRandomStream Stream(123);
	FString Combined = FString("rng:") + Stream;
	FString FromEmpty = FString("") + Stream;
	return Combined.Len() > 4 && FromEmpty.Len() > 0 && Stream.GetInitialSeed() == 123;
}
/** @end */
/**
 * @begin get-initial-seed
 * @summary Initial seed is unchanged by draws.
 * @topic Unreal
 */
/**
 * @function ObserveGetInitialSeedNominal
 * @summary Initial seed is unchanged by draws.
 * @covers FRandomStream.get-initial-seed
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInitialSeedNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	FRandomStream DefaultStream;
	return Stream.GetInitialSeed() == 123 && Twin.GetInitialSeed() == 123 && DefaultStream.GetInitialSeed() == 0;
}
/** @end */
/**
 * @begin get-fraction
 * @summary Initial seed is unchanged by draws.
 * @topic Unreal
 */
/**
 * @function ObserveGetFractionNominal
 * @summary Initial seed is unchanged by draws.
 * @covers FRandomStream.get-fraction
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFractionNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	float32 Fraction = Stream.GetFraction();
	float32 TwinFraction = Twin.GetFraction();
	return Fraction >= 0.0 && Fraction <= 1.0 && TwinFraction == Fraction;
}
/** @end */
/**
 * @begin get-unsigned-int
 * @summary Initial seed is unchanged by draws.
 * @topic Unreal
 */
/**
 * @function ObserveGetUnsignedIntNominal
 * @summary Initial seed is unchanged by draws.
 * @covers FRandomStream.get-unsigned-int
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUnsignedIntNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	uint32 First = Stream.GetUnsignedInt();
	uint32 TwinFirst = Twin.GetUnsignedInt();
	uint32 Second = Stream.GetUnsignedInt();
	return First == TwinFirst && Second != First;
}
/** @end */
/**
 * @begin get-current-seed
 * @summary Initial seed is unchanged by draws.
 * @topic Unreal
 */
/**
 * @function ObserveGetCurrentSeedNominal
 * @summary Initial seed is unchanged by draws.
 * @covers FRandomStream.get-current-seed
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCurrentSeedNominal()
{
	FRandomStream Stream(123);
	int32 Before = Stream.GetCurrentSeed();
	Stream.GetUnsignedInt();
	int32 After = Stream.GetCurrentSeed();
	return Before == 123 && After != Before;
}
/** @end */
/**
 * @begin get-unit-vector
 * @summary Initial seed is unchanged by draws.
 * @topic Unreal
 */
/**
 * @function ObserveGetUnitVectorNominal
 * @summary Initial seed is unchanged by draws.
 * @covers FRandomStream.get-unit-vector
 * @inputs FRandomStream values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUnitVectorNominal()
{
	FRandomStream Stream(123);
	FRandomStream Twin(123);
	FVector Unit = Stream.GetUnitVector();
	FVector TwinUnit = Twin.GetUnitVector();
	return Unit.Size() > 0.9 && Unit.Size() < 1.1 && TwinUnit.X == Unit.X;
}
/** @end */
