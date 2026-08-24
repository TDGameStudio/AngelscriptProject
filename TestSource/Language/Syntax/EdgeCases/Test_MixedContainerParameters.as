// Theme: Language.Syntax.EdgeCases. WorldStory mixed container parameters.
// C++: AngelscriptCoverageContainerParameterTests.cpp::MixedContainerParameters
// sha256=38a3fe19a6d4dfda9377347c1b8d0e89813ce13573780a9cdc0458e13a4acb2d; lines 449-510.
// Oracle after BeginPlay: ResultSize=7 (2+3+2). Extra: empty containers sum to
// 0; SetToArray of empty set is empty. FixtureIsolated.

UCLASS()
class ACoverageContainerParamMixedActor : AActor
{
	UPROPERTY()
	int ResultSize;

	// Function taking multiple container types
	int ProcessMultipleContainers(
		const TArray<int>&in Arr,
		const TMap<int, FString>&in Map,
		const TSet<int>&in Set)
	{
		Print("=== ProcessMultipleContainers ===");
		Print("Array size: " + Arr.Num());
		Print("Map size: " + Map.Num());
		Print("Set size: " + Set.Num());
		return Arr.Num() + Map.Num() + Set.Num();
	}

	// Function returning different containers based on input
	TArray<int> SetToArray(const TSet<int>&in InputSet)
	{
		Print("=== SetToArray ===");
		TArray<int> Result;
		for (int Val : InputSet)
		{
			Result.Add(Val);
		}
		Print("Converted " + InputSet.Num() + " elements to array");
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Mixed Container Parameters Test ===");

		TArray<int> MyArray;
		MyArray.Add(1);
		MyArray.Add(2);

		TMap<int, FString> MyMap;
		MyMap.Add(1, "One");
		MyMap.Add(2, "Two");
		MyMap.Add(3, "Three");

		TSet<int> MySet;
		MySet.Add(10);
		MySet.Add(20);

		ResultSize = ProcessMultipleContainers(MyArray, MyMap, MySet);

		// Test conversion
		TSet<int> ConvertSet;
		ConvertSet.Add(100);
		ConvertSet.Add(200);
		TArray<int> ConvertedArray = SetToArray(ConvertSet);
		Print("Converted array size: " + ConvertedArray.Num());
	}
}

bool Observe_MixedContainers_DefaultEmpty(ACoverageContainerParamMixedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedContainerParameters setup: required Actor is null");
	}
	return Actor.ResultSize == 0;
}

bool Observe_MixedContainers_Nominal(ACoverageContainerParamMixedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedContainerParameters setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ResultSize == 7;
}

bool Observe_MixedContainers_EmptyBoundary(ACoverageContainerParamMixedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedContainerParameters setup: required Actor is null");
	}
	TArray<int> EmptyArr;
	TMap<int, FString> EmptyMap;
	TSet<int> EmptySet;
	TArray<int> Converted = Actor.SetToArray(EmptySet);
	return Actor.ProcessMultipleContainers(EmptyArr, EmptyMap, EmptySet) == 0 && Converted.Num() == 0;
}
