// Theme: Definitions.UStruct. WorldStory: nested FInnerIntData defaults through FOuterIntData.
// C++: AngelscriptCoverageUStructMemberTests.cpp::NestedStructIntegerMembers
// lines 85-132;
// sha256=585b0504de3abe83616c1ad5986907ad101f8e8827fc6431c5c1245e9df010d6.
// Oracle: Data.Inner.Int8Value=-42, Int16Value=-12345, Int32Value=-987654,
// Int64Value=-9000000000, UInt8Value=200, UInt16Value=54321, UInt32Value=3000000000,
// UInt64Value=12000000000, Data.OuterValue=999.
// Extra: FInnerIntData constructed empty-of-actor still carries those defaults;
// copy-independence after mutating the copy.
// FixtureIsolated.

USTRUCT()
struct FInnerIntData
{
	UPROPERTY()
	int8 Int8Value = -42;

	UPROPERTY()
	int16 Int16Value = -12345;

	UPROPERTY()
	int Int32Value = -987654;

	UPROPERTY()
	int64 Int64Value = -9000000000;

	UPROPERTY()
	uint8 UInt8Value = 200;

	UPROPERTY()
	uint16 UInt16Value = 54321;

	UPROPERTY()
	uint UInt32Value = 3000000000;

	UPROPERTY()
	uint64 UInt64Value = 12000000000;
}

USTRUCT()
struct FOuterIntData
{
	UPROPERTY()
	FInnerIntData Inner;

	UPROPERTY()
	int OuterValue = 999;
}

UCLASS()
class ACoverageNestedStructActor : AActor
{
	UPROPERTY()
	FOuterIntData Data;
}

bool Observe_NestedInt_Defaults()
{
	FOuterIntData Data;
	return Data.Inner.Int8Value == -42
		&& Data.Inner.Int16Value == -12345
		&& Data.Inner.Int32Value == -987654
		&& Data.Inner.Int64Value == -9000000000
		&& Data.Inner.UInt8Value == 200
		&& Data.Inner.UInt16Value == 54321
		&& Data.Inner.UInt32Value == 3000000000
		&& Data.Inner.UInt64Value == 12000000000
		&& Data.OuterValue == 999;
}

bool Observe_NestedInt_CopyIndependence()
{
	FOuterIntData Original;
	FOuterIntData Copy = Original;
	Copy.Inner.Int32Value = 0;
	Copy.OuterValue = 0;
	return Original.Inner.Int32Value == -987654 && Original.OuterValue == 999
		&& Copy.Inner.Int32Value == 0 && Copy.OuterValue == 0;
}
