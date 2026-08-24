// Theme: Definitions.UStruct. WorldStory: USTRUCT, plain struct, nested USTRUCT.
// C++: AngelscriptCoverageUStructTests.cpp::UStructBasicDeclaration
// lines 1710-1758;
// sha256=925768351410941224246d4a6d956dd5c2e159e3c0c33ee124cbb7909f18763b.
// Oracle after BeginPlay: SimpleData.Value=99, NestedData.OuterValue=200,
// NestedData.InnerStruct.Value=300.
// Extra: FSimpleStruct default 42; FPlainStruct empty defaults 10/20; copy-independence.
// FixtureIsolated.

USTRUCT()
struct FSimpleStruct
{
	UPROPERTY()
	int Value = 42;
}

struct FPlainStruct
{
	int X = 10;
	int Y = 20;
}

USTRUCT()
struct FNestedOuter
{
	UPROPERTY()
	int OuterValue = 100;

	UPROPERTY()
	FSimpleStruct InnerStruct;
}

UCLASS()
class ACoverageStructBasicActor : AActor
{
	UPROPERTY()
	FSimpleStruct SimpleData;

	UPROPERTY()
	FNestedOuter NestedData;

	FPlainStruct PlainData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SimpleData.Value = 99;
		NestedData.OuterValue = 200;
		NestedData.InnerStruct.Value = 300;
		PlainData.X = 50;
		PlainData.Y = 75;
	}
}

bool Observe_Simple_DefaultEmpty()
{
	FSimpleStruct SimpleData;
	return SimpleData.Value == 42;
}

bool Observe_Plain_DefaultEmpty()
{
	FPlainStruct PlainData;
	return PlainData.X == 10 && PlainData.Y == 20;
}

bool Observe_Nested_DefaultInner()
{
	FNestedOuter NestedData;
	return NestedData.OuterValue == 100 && NestedData.InnerStruct.Value == 42;
}

bool Observe_Simple_CopyIndependence()
{
	FSimpleStruct Original;
	FSimpleStruct Copy = Original;
	Copy.Value = 0;
	return Original.Value == 42 && Copy.Value == 0;
}
