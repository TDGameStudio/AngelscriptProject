// Theme: Definitions.UFunction. WorldStory int/int64/uint UFUNCTION plus &out.
// C++: AngelscriptCoverageIntFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: AddInts(20,22)==42; MultiplyInt64(5000000000,2)==10000000000; SubtractUInt(3000000042,42)==3000000000; WriteOut 999.
// Extra: AddInts(0,0) empty; nullptr actor is the empty handle; addends unchanged after sum.
// FixtureIsolated.

UCLASS()
class ACoverageIntFunctionActor : AActor
{
	UFUNCTION()
	int AddInts(int a, int b)
	{
		return a + b;
	}

	UFUNCTION()
	int64 MultiplyInt64(int64 x, int64 y)
	{
		return x * y;
	}

	UFUNCTION()
	uint SubtractUInt(uint a, uint b)
	{
		return a - b;
	}

	UFUNCTION()
	void WriteOut(int&out result)
	{
		result = 999;
	}
}

bool Observe_IntFunction_Nominal(ACoverageIntFunctionActor Actor)
{
	int OutValue = 0;
	Actor.WriteOut(OutValue);
	return Actor.AddInts(20, 22) == 42
		&& Actor.MultiplyInt64(5000000000, 2) == 10000000000
		&& Actor.SubtractUInt(3000000042, 42) == 3000000000
		&& OutValue == 999;
}

bool Observe_IntFunction_ZeroEmpty(ACoverageIntFunctionActor Actor)
{
	return Actor.AddInts(0, 0) == 0 && Actor.MultiplyInt64(0, 0) == 0;
}

bool Observe_IntFunction_NullDefault()
{
	ACoverageIntFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_IntFunction_CopyIndependence(ACoverageIntFunctionActor Actor)
{
	int A = 20;
	int B = 22;
	int Sum = Actor.AddInts(A, B);
	return A == 20 && B == 22 && Sum == 42;
}
