// Theme: Language.ControlFlow.Jump. WorldStory lifecycle oracle from ContainerAsReturnValue.
// C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerAsReturnValue
// sha256=199d3779fe6cdbe8de77cd641a1b4979051ebdf219b678d0c91c9123d70bd767; lines 169-216.
// Oracle: VerifyByPath ArraySize == 3; MapSize == 2 after BeginPlay.
// Extra: empty container helpers return Num 0; ArrayFirst keeps 10 independently of MapSize.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageContainerReturnActor : AActor
{
	UPROPERTY()
	int ArraySize;

	UPROPERTY()
	int MapSize;

	UPROPERTY()
	int ArrayFirst;

	UPROPERTY()
	int EmptyArraySize;

	UPROPERTY()
	int EmptyMapSize;

	TArray<int> MakeArray()
	{
		Print("=== MakeArray ===");
		TArray<int> Result;
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Print("Created array with " + Result.Num() + " elements");
		return Result;
	}

	TMap<int, FString> MakeMap()
	{
		Print("=== MakeMap ===");
		TMap<int, FString> Result;
		Result.Add(1, "One");
		Result.Add(2, "Two");
		Print("Created map with " + Result.Num() + " entries");
		return Result;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Container as Return Value Test ===");

		TArray<int> MyArray = MakeArray();
		ArraySize = MyArray.Num();
		ArrayFirst = MyArray[0];
		Print("Received array size: " + ArraySize);

		TMap<int, FString> MyMap = MakeMap();
		MapSize = MyMap.Num();
		Print("Received map size: " + MapSize);

		TArray<int> EmptyArray;
		EmptyArraySize = EmptyArray.Num();
		TMap<int, FString> EmptyMap;
		EmptyMapSize = EmptyMap.Num();
	}
}
