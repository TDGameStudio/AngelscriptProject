// Theme: Definitions.UStruct. WorldStory: nested FInner/FMiddle/FOuter structs and arrays.
// C++: AngelscriptCoverageUStructTests.cpp::UStructNested spawn + BeginPlay.
// Oracle: OuterValue 100, MiddleValue 200, Inner 300/DeepInner, DirectInner 400/DirectInner,
// InnerArray 301/302, MiddleArray 201/202. Extra: zeros and empty arrays before BeginPlay.
// FixtureIsolated.

USTRUCT()
struct FInnerStruct
{
	UPROPERTY()
	int InnerValue = 0;

	UPROPERTY()
	FString InnerName;
}

USTRUCT()
struct FMiddleStruct
{
	UPROPERTY()
	int MiddleValue = 0;

	UPROPERTY()
	FInnerStruct InnerData;

	UPROPERTY()
	TArray<FInnerStruct> InnerArray;
}

USTRUCT()
struct FOuterStruct
{
	UPROPERTY()
	int OuterValue = 0;

	UPROPERTY()
	FMiddleStruct MiddleData;

	UPROPERTY()
	FInnerStruct DirectInner;

	UPROPERTY()
	TArray<FMiddleStruct> MiddleArray;
}

UCLASS()
class ACoverageStructNestedActor : AActor
{
	UPROPERTY()
	FOuterStruct NestedData;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Set outer level
		NestedData.OuterValue = 100;

		// Set middle level
		NestedData.MiddleData.MiddleValue = 200;

		// Set inner level (through middle)
		NestedData.MiddleData.InnerData.InnerValue = 300;
		NestedData.MiddleData.InnerData.InnerName = "DeepInner";

		// Set direct inner
		NestedData.DirectInner.InnerValue = 400;
		NestedData.DirectInner.InnerName = "DirectInner";

		// Set array of inner structs in middle
		FInnerStruct Inner1;
		Inner1.InnerValue = 301;
		Inner1.InnerName = "Inner1";
		NestedData.MiddleData.InnerArray.Add(Inner1);

		FInnerStruct Inner2;
		Inner2.InnerValue = 302;
		Inner2.InnerName = "Inner2";
		NestedData.MiddleData.InnerArray.Add(Inner2);

		// Set array of middle structs
		FMiddleStruct Middle1;
		Middle1.MiddleValue = 201;
		Middle1.InnerData.InnerValue = 311;
		Middle1.InnerData.InnerName = "MiddleArray1Inner";
		NestedData.MiddleArray.Add(Middle1);

		FMiddleStruct Middle2;
		Middle2.MiddleValue = 202;
		Middle2.InnerData.InnerValue = 312;
		Middle2.InnerData.InnerName = "MiddleArray2Inner";
		NestedData.MiddleArray.Add(Middle2);
	}
}

bool Observe_Nested_DefaultEmpty(ACoverageStructNestedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructNested setup: required Actor is null");
	}
	return Actor.NestedData.OuterValue == 0
		&& Actor.NestedData.MiddleData.MiddleValue == 0
		&& Actor.NestedData.MiddleData.InnerData.InnerValue == 0
		&& Actor.NestedData.DirectInner.InnerName.Len() == 0
		&& Actor.NestedData.MiddleData.InnerArray.Num() == 0
		&& Actor.NestedData.MiddleArray.Num() == 0;
}

bool Observe_Nested_NominalBeginPlay(ACoverageStructNestedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructNested setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.NestedData.OuterValue == 100
		&& Actor.NestedData.MiddleData.MiddleValue == 200
		&& Actor.NestedData.MiddleData.InnerData.InnerValue == 300
		&& Actor.NestedData.MiddleData.InnerData.InnerName == "DeepInner"
		&& Actor.NestedData.DirectInner.InnerValue == 400
		&& Actor.NestedData.DirectInner.InnerName == "DirectInner"
		&& Actor.NestedData.MiddleData.InnerArray.Num() == 2
		&& Actor.NestedData.MiddleData.InnerArray[0].InnerValue == 301
		&& Actor.NestedData.MiddleData.InnerArray[1].InnerName == "Inner2"
		&& Actor.NestedData.MiddleArray.Num() == 2
		&& Actor.NestedData.MiddleArray[0].MiddleValue == 201
		&& Actor.NestedData.MiddleArray[1].InnerData.InnerValue == 312;
}

bool Observe_Nested_CopyIndependence(ACoverageStructNestedActor First, ACoverageStructNestedActor Second)
{
	if (First is null)
	{
		throw("Test_UStructNested setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_UStructNested setup: required Second is null");
	}
	First.BeginPlay();
	return First.NestedData.OuterValue == 100 && Second.NestedData.OuterValue == 0 && Second.NestedData.MiddleArray.Num() == 0;
}
