// Theme: Definitions.UStruct. WorldStory: FBoundaryIntData fields default 0; C++ SetByPath
// then VerifyByPath min/max for every integer width.
// C++: AngelscriptCoverageUStructMemberTests.cpp::StructIntegerBoundaryValues
// lines 270-317;
// sha256=4805b23eac0b3f214a684e16a0084946908710315e4a044e47e803636c5ac546.
// Oracle names: Data.Int8Min/Max, Int16Min/Max, Int32Min/Max, Int64Min/Max,
// UInt8Max, UInt16Max, UInt32Max, UInt64Max. Defaults are 0 before C++ writes.
// Extra: local FBoundaryIntData is the empty/default zero vector; copy-independence.
// FixtureIsolated.

USTRUCT()
struct FBoundaryIntData
{
	UPROPERTY()
	int8 Int8Min = 0;

	UPROPERTY()
	int8 Int8Max = 0;

	UPROPERTY()
	int16 Int16Min = 0;

	UPROPERTY()
	int16 Int16Max = 0;

	UPROPERTY()
	int Int32Min = 0;

	UPROPERTY()
	int Int32Max = 0;

	UPROPERTY()
	int64 Int64Min = 0;

	UPROPERTY()
	int64 Int64Max = 0;

	UPROPERTY()
	uint8 UInt8Max = 0;

	UPROPERTY()
	uint16 UInt16Max = 0;

	UPROPERTY()
	uint UInt32Max = 0;

	UPROPERTY()
	uint64 UInt64Max = 0;
}

UCLASS()
class ACoverageBoundaryStructActor : AActor
{
	UPROPERTY()
	FBoundaryIntData Data;
}

bool Observe_BoundaryInt_EmptyDefaults()
{
	FBoundaryIntData Data;
	return Data.Int8Min == 0 && Data.Int8Max == 0
		&& Data.Int16Min == 0 && Data.Int16Max == 0
		&& Data.Int32Min == 0 && Data.Int32Max == 0
		&& Data.Int64Min == 0 && Data.Int64Max == 0
		&& Data.UInt8Max == 0 && Data.UInt16Max == 0
		&& Data.UInt32Max == 0 && Data.UInt64Max == 0;
}

bool Observe_BoundaryInt_CopyIndependence()
{
	FBoundaryIntData Original;
	FBoundaryIntData Copy = Original;
	Copy.Int8Min = -128;
	Copy.Int8Max = 127;
	return Original.Int8Min == 0 && Original.Int8Max == 0
		&& Copy.Int8Min == -128 && Copy.Int8Max == 127;
}
