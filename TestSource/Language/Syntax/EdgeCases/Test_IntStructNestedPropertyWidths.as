// Theme: Language.Syntax.EdgeCases. WorldStory: nested USTRUCT int-family widths.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntStructNestedPropertyWidths
// sha256=492fad1780fecd6a0bb3f67d4080077b90b358720a1990eadf61e5ffd7034c96; lines 1284-1319.
// Oracle: Stats reflects as FStructProperty with int8/int16/int/int64/uint8/uint16/uint/uint64 members;
// defaults Int8Value -12; Int16Value -1234; IntValue 123456; Int64Value -9000000000;
// UInt8Value 250; UInt16Value 60000; UIntValue 3000000000; UInt64Value 12000000000000000000.
// Extra: local construct reads those USTRUCT defaults (empty actor, no BeginPlay).
// FixtureIsolated. Struct owns the nested integers.

USTRUCT()
struct FCoverageIntNestedWidths
{
	UPROPERTY()
	int8 Int8Value = -12;

	UPROPERTY()
	int16 Int16Value = -1234;

	UPROPERTY()
	int IntValue = 123456;

	UPROPERTY()
	int64 Int64Value = -9000000000;

	UPROPERTY()
	uint8 UInt8Value = 250;

	UPROPERTY()
	uint16 UInt16Value = 60000;

	UPROPERTY()
	uint UIntValue = 3000000000;

	UPROPERTY()
	uint64 UInt64Value = 12000000000000000000;
}

UCLASS()
class ACoverageIntStructNestedWidthsActor : AActor
{
	UPROPERTY()
	FCoverageIntNestedWidths Stats;
}

bool Observe_IntStructNestedWidths_Nominal(ACoverageIntStructNestedWidthsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntStructNestedPropertyWidths setup: required Actor is null");
	}
	return Actor.Stats.Int8Value == -12
		&& Actor.Stats.Int16Value == -1234
		&& Actor.Stats.IntValue == 123456
		&& Actor.Stats.Int64Value == -9000000000
		&& Actor.Stats.UInt8Value == 250
		&& Actor.Stats.UInt16Value == 60000
		&& Actor.Stats.UIntValue == 3000000000
		&& Actor.Stats.UInt64Value == 12000000000000000000;
}

bool Observe_IntStructNestedWidths_CopyIndependence(ACoverageIntStructNestedWidthsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntStructNestedPropertyWidths setup: required Actor is null");
	}
	FCoverageIntNestedWidths Copy = Actor.Stats;
	Copy.IntValue = 0;
	return Actor.Stats.IntValue == 123456 && Copy.IntValue == 0;
}
