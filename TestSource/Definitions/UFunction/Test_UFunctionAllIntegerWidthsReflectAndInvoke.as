// Theme: Definitions.UFunction. WorldStory every integer width UFUNCTION echo+offset.
// C++: AngelscriptCoverageIntFunctionTests.cpp::UFunctionAllIntegerWidthsReflectAndInvoke
// Oracle: EchoInt8(41)==42; EchoInt16(29998)==30000; EchoInt(39)==42; EchoInt64(9999999996)==10000000000;
// EchoUInt8(250)==255; EchoUInt16(59994)==60000; EchoUInt(2999999993)==3000000000;
// EchoUInt64(11999999999999999992)==12000000000000000000.
// Extra: EchoInt(0)==3 empty seed; nullptr actor is the empty handle; uint8 250 is the near-max boundary.
// FixtureIsolated.

UCLASS()
class ACoverageIntFunctionWidthsActor : AActor
{
	UFUNCTION()
	int8 EchoInt8(int8 Value)
	{
		return Value + 1;
	}

	UFUNCTION()
	int16 EchoInt16(int16 Value)
	{
		return Value + 2;
	}

	UFUNCTION()
	int EchoInt(int Value)
	{
		return Value + 3;
	}

	UFUNCTION()
	int64 EchoInt64(int64 Value)
	{
		return Value + 4;
	}

	UFUNCTION()
	uint8 EchoUInt8(uint8 Value)
	{
		return Value + 5;
	}

	UFUNCTION()
	uint16 EchoUInt16(uint16 Value)
	{
		return Value + 6;
	}

	UFUNCTION()
	uint EchoUInt(uint Value)
	{
		return Value + 7;
	}

	UFUNCTION()
	uint64 EchoUInt64(uint64 Value)
	{
		return Value + 8;
	}
}

bool Observe_IntWidths_Nominal(ACoverageIntFunctionWidthsActor Actor)
{
	return Actor.EchoInt8(41) == 42
		&& Actor.EchoInt16(29998) == 30000
		&& Actor.EchoInt(39) == 42
		&& Actor.EchoInt64(9999999996) == 10000000000
		&& Actor.EchoUInt8(250) == 255
		&& Actor.EchoUInt16(59994) == 60000
		&& Actor.EchoUInt(2999999993) == 3000000000
		&& Actor.EchoUInt64(11999999999999999992) == 12000000000000000000;
}

bool Observe_IntWidths_ZeroEmpty(ACoverageIntFunctionWidthsActor Actor)
{
	return Actor.EchoInt8(0) == 1
		&& Actor.EchoInt(0) == 3
		&& Actor.EchoUInt8(0) == 5
		&& Actor.EchoUInt64(0) == 8;
}

bool Observe_IntWidths_NullDefault()
{
	ACoverageIntFunctionWidthsActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_IntWidths_Uint8MaxBoundary(ACoverageIntFunctionWidthsActor Actor)
{
	return Actor.EchoUInt8(250) == 255 && Actor.EchoUInt8(0) == 5;
}
