// Theme: Definitions.UStruct. WorldStory: flat FFlatIntData integer defaults.
// C++: AngelscriptCoverageUStructMemberTests.cpp::FlatStructIntegerMembers
// lines 194-229;
// sha256=dd80bb2efa4f944d08f7c04f230cab9ca01482067243e32ff83241f497f00813.
// Oracle: StructData.Int8Value=10, Int16Value=1000, Int32Value=100000,
// Int64Value=10000000000, UInt8Value=255, UInt16Value=65000, UInt32Value=4000000000,
// UInt64Value=18000000000000000000.
// Extra: local FFlatIntData carries the same defaults; copy-independence after mutate.
// FixtureIsolated.

USTRUCT()
struct FFlatIntData
{
	UPROPERTY()
	int8 Int8Value = 10;

	UPROPERTY()
	int16 Int16Value = 1000;

	UPROPERTY()
	int Int32Value = 100000;

	UPROPERTY()
	int64 Int64Value = 10000000000;

	UPROPERTY()
	uint8 UInt8Value = 255;

	UPROPERTY()
	uint16 UInt16Value = 65000;

	UPROPERTY()
	uint UInt32Value = 4000000000;

	UPROPERTY()
	uint64 UInt64Value = 18000000000000000000;
}

UCLASS()
class ACoverageFlatStructActor : AActor
{
	UPROPERTY()
	FFlatIntData StructData;
}

bool Observe_FlatInt_Defaults()
{
	FFlatIntData StructData;
	return StructData.Int8Value == 10
		&& StructData.Int16Value == 1000
		&& StructData.Int32Value == 100000
		&& StructData.Int64Value == 10000000000
		&& StructData.UInt8Value == 255
		&& StructData.UInt16Value == 65000
		&& StructData.UInt32Value == 4000000000
		&& StructData.UInt64Value == 18000000000000000000;
}

bool Observe_FlatInt_CopyIndependence()
{
	FFlatIntData Original;
	FFlatIntData Copy = Original;
	Copy.Int32Value = 0;
	Copy.UInt8Value = 0;
	return Original.Int32Value == 100000 && Original.UInt8Value == 255
		&& Copy.Int32Value == 0 && Copy.UInt8Value == 0;
}
