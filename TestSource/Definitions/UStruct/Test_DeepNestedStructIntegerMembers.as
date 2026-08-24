// Theme: Definitions.UStruct. WorldStory: three-level Root.Middle.Inner integer defaults.
// C++: AngelscriptCoverageUStructMemberTests.cpp::DeepNestedStructIntegerMembers
// lines 376-416;
// sha256=62c97317d9d64712f54f82e9649bef2bb0cdc56c76d824d8854bf4f14593a695.
// Oracle: Root.Middle.Inner.Int8Value=7, UInt64Value=999999999,
// Root.Middle.Int16Value=777, Root.Int32Value=12345.
// Extra: local FOutermost carries those defaults; copy-independence after mutate.
// FixtureIsolated.

USTRUCT()
struct FInnermost
{
	UPROPERTY()
	int8 Int8Value = 7;

	UPROPERTY()
	uint64 UInt64Value = 999999999;
}

USTRUCT()
struct FMiddleLayer
{
	UPROPERTY()
	FInnermost Inner;

	UPROPERTY()
	int16 Int16Value = 777;
}

USTRUCT()
struct FOutermost
{
	UPROPERTY()
	FMiddleLayer Middle;

	UPROPERTY()
	int Int32Value = 12345;
}

UCLASS()
class ACoverageDeepNestedActor : AActor
{
	UPROPERTY()
	FOutermost Root;
}

bool Observe_DeepNested_Defaults()
{
	FOutermost Root;
	return Root.Middle.Inner.Int8Value == 7
		&& Root.Middle.Inner.UInt64Value == 999999999
		&& Root.Middle.Int16Value == 777
		&& Root.Int32Value == 12345;
}

bool Observe_DeepNested_CopyIndependence()
{
	FOutermost Original;
	FOutermost Copy = Original;
	Copy.Middle.Inner.Int8Value = -100;
	Copy.Int32Value = 0;
	return Original.Middle.Inner.Int8Value == 7 && Original.Int32Value == 12345
		&& Copy.Middle.Inner.Int8Value == -100 && Copy.Int32Value == 0;
}
