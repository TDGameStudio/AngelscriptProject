// Theme: Language.Operators.Arithmetic. Positive: FColor packing and deterministic FRandomStream.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::ColorAndRandomStreamStructExpressions ExpectGlobalReturn.
// sha256=e3ab53fdf45b32ecc721358863d528181c804e91807c2c4418140b417df50eaa; lines 1071-1146.
// Oracle: TestFColorConstruction == FColor(10,20,30,40);
// TestFColorConstantsAndHex == FColor::Red;
// TestFLinearColorToFColor == FColor(255,128,0,255);
// InitFromString/add/constants true; Reset/seed true; vector helpers true.
// RandomStream int range matches native sequence in C++; here observe inclusive [10,20].
// Extra: default FColor is (0,0,0,0); Transparent is the empty/zero color.
// DefaultSafe. Use Math:: for nearly-equal linear channels.

FColor TestFColorConstruction()
{
	return FColor(10, 20, 30, 40);
}

FColor TestFColorConstantsAndHex()
{
	return FColor::FromHex(FColor::Red.ToHex());
}

FLinearColor TestFColorReinterpretAsLinear()
{
	return FColor(128, 64, 32, 255).ReinterpretAsLinear();
}

FColor TestFLinearColorToFColor()
{
	return FLinearColor(1.0, 0.5, 0.0, 1.0).ToFColor(false);
}

bool TestFColorInitFromStringAndAddAssign()
{
	FColor Color;
	bool bInitialized = Color.InitFromString("(R=10,G=20,B=30,A=40)");
	Color += FColor(1, 2, 3, 4);
	return bInitialized
		&& Color == FColor(11, 22, 33, 44)
		&& FColor::White == FColor(255, 255, 255, 255)
		&& FColor::Transparent == FColor(0, 0, 0, 0);
}

int TestRandomStreamIntRange()
{
	FRandomStream Stream(12345);
	return Stream.RandRange(10, 20);
}

double TestRandomStreamDoubleRange()
{
	FRandomStream Stream(12345);
	Stream.RandRange(10, 20);
	return Stream.RandRange(1.0, 2.0);
}

uint TestRandomStreamUnsigned()
{
	FRandomStream Stream(12345);
	Stream.RandRange(10, 20);
	Stream.RandRange(1.0, 2.0);
	return Stream.GetUnsignedInt();
}

bool TestRandomStreamResetAndSeed()
{
	FRandomStream Stream(12345);
	int First = Stream.RandRange(10, 20);
	Stream.RandRange(1.0, 2.0);
	Stream.Reset();
	int ResetFirst = Stream.RandRange(10, 20);
	return Stream.GetInitialSeed() == 12345
		&& First == ResetFirst;
}

bool TestRandomStreamVectors()
{
	FRandomStream Stream(12345);
	FVector Unit = Stream.GetUnitVector();
	FVector Random = Stream.VRand();
	FVector Cone = Stream.VRandCone(FVector(1, 0, 0), 0.25f);
	return Unit.IsUnit(0.001)
		&& Random.IsUnit(0.001)
		&& Cone.IsUnit(0.001)
		&& Cone.X > 0.9;
}

bool Observe_FColor_Nominal()
{
	return TestFColorConstruction() == FColor(10, 20, 30, 40)
		&& TestFColorConstantsAndHex() == FColor::Red
		&& TestFLinearColorToFColor() == FColor(255, 128, 0, 255)
		&& TestFColorInitFromStringAndAddAssign();
}

bool Observe_ReinterpretAsLinear_Nominal()
{
	FLinearColor Result = TestFColorReinterpretAsLinear();
	return Math::IsNearlyEqual(Result.R, 128.0 / 255.0, 0.001)
		&& Math::IsNearlyEqual(Result.G, 64.0 / 255.0, 0.001)
		&& Math::IsNearlyEqual(Result.B, 32.0 / 255.0, 0.001)
		&& Math::IsNearlyEqual(Result.A, 1.0, 0.001);
}

bool Observe_FColor_DefaultEmpty()
{
	FColor Color;
	return Color == FColor(0, 0, 0, 0) && Color == FColor::Transparent;
}

bool Observe_RandomStream_Nominal()
{
	int IntRange = TestRandomStreamIntRange();
	double DoubleRange = TestRandomStreamDoubleRange();
	return IntRange >= 10 && IntRange <= 20
		&& DoubleRange >= 1.0 && DoubleRange <= 2.0
		&& TestRandomStreamResetAndSeed()
		&& TestRandomStreamVectors();
}
