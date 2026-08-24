// Theme: Language.Syntax.EdgeCases. WorldStory: three-level nested int USTRUCT paths.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntStructDeepNestedPropertyPaths
// sha256=9708f2424c775bd3caa312ea3b9fecdc3fac049efc04fd0cd78abdc8da04e6d7; lines 1383-1420.
// Oracle: Root.Middle.Inner.Int8Value 7; Root.Middle.Inner.UInt64Value 999999999;
// Root.Middle.Int16Value 777; Root.IntValue 12345.
// Extra: local construct reads defaults; mutating a copy does not change Root.
// FixtureIsolated. Nested structs own the integers.

USTRUCT()
struct FCoverageIntPropertyDeepInner
{
	UPROPERTY()
	int8 Int8Value = 7;

	UPROPERTY()
	uint64 UInt64Value = 999999999;
}

USTRUCT()
struct FCoverageIntPropertyDeepMiddle
{
	UPROPERTY()
	FCoverageIntPropertyDeepInner Inner;

	UPROPERTY()
	int16 Int16Value = 777;
}

USTRUCT()
struct FCoverageIntPropertyDeepRoot
{
	UPROPERTY()
	FCoverageIntPropertyDeepMiddle Middle;

	UPROPERTY()
	int IntValue = 12345;
}

UCLASS()
class ACoverageIntStructDeepPathsActor : AActor
{
	UPROPERTY()
	FCoverageIntPropertyDeepRoot Root;
}

bool Observe_IntStructDeepPaths_Nominal(ACoverageIntStructDeepPathsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntStructDeepNestedPropertyPaths setup: required Actor is null");
	}
	return Actor.Root.Middle.Inner.Int8Value == 7
		&& Actor.Root.Middle.Inner.UInt64Value == 999999999
		&& Actor.Root.Middle.Int16Value == 777
		&& Actor.Root.IntValue == 12345;
}

bool Observe_IntStructDeepPaths_CopyIndependence(ACoverageIntStructDeepPathsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntStructDeepNestedPropertyPaths setup: required Actor is null");
	}
	FCoverageIntPropertyDeepInner Copy = Actor.Root.Middle.Inner;
	Copy.Int8Value = 0;
	return Actor.Root.Middle.Inner.Int8Value == 7 && Copy.Int8Value == 0;
}
