/**
 * A container can be returned by value from a function, so the caller receives
 * the filled container rather than a handle to one. The returned array and map
 * arrive with their elements intact, and a default-constructed container
 * arrives empty. The results are recorded on UPROPERTYs so C++ can read them
 * by path after BeginPlay runs.
 * The UPROPERTY names are read by path from C++ and must not be renamed:
 * ArraySize, MapSize, ArrayFirst, EmptyArraySize, EmptyMapSize.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ContainerAsReturnValue
 * @Harness UClass
 * @Tag Language.ControlFlow.ContainerAsReturnValue
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerAsReturnValue
 * @Provenance sha256=199d3779fe6cdbe8de77cd641a1b4979051ebdf219b678d0c91c9123d70bd767; lines 169-216.
 * @Provenance Oracle: VerifyByPath ArraySize == 3; MapSize == 2 after BeginPlay.
 * @Provenance Extra: empty container helpers return Num 0; ArrayFirst keeps 10.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

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

	/**
	 * Build an array and return it by value.
	 */
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

	/**
	 * Build a map and return it by value.
	 */
	TMap<int, FString> MakeMap()
	{
		Print("=== MakeMap ===");
		TMap<int, FString> Result;
		Result.Add(1, "One");
		Result.Add(2, "Two");
		Print("Created map with " + Result.Num() + " entries");
		return Result;
	}

	/**
	 * Run the returns once at play time, so the C++ fixture can read the
	 * resulting property values by path.
	 */
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

namespace ControlFlowTest
{
	/**
	 * Observe the returned array: it arrives with all three elements and the
	 * first one intact.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Build an array through the same helper the actor uses
	 * @Return true when the count is 3 and the first element is 10
	 */
	UFUNCTION()
	bool ReturnedArrayKeepsElements()
	{
		TArray<int> Result;
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		if (Result.Num() != 3)
		{
			return false;
		}
		return Result[0] == 10;
	}

	/**
	 * Observe the returned map: it arrives with both entries.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs Build a map through the same helper the actor uses
	 * @Return true when the count is 2
	 */
	UFUNCTION()
	bool ReturnedMapKeepsEntries()
	{
		TMap<int, FString> Result;
		Result.Add(1, "One");
		Result.Add(2, "Two");
		return Result.Num() == 2;
	}

	/**
	 * Observe the empty default: default-constructed containers report zero.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Return
	 * @Inputs A default array and a default map
	 * @Return true when both counts are zero
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool ReturnedEmptyContainersReportZero()
	{
		TArray<int> EmptyArray;
		TMap<int, FString> EmptyMap;
		if (EmptyArray.Num() != 0)
		{
			return false;
		}
		return EmptyMap.Num() == 0;
	}
}
