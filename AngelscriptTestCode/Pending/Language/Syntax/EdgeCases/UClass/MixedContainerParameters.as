/**
 * @version v1
 * @summary One function receiving all three container kinds by const reference, plus a converter from TSet to TArray. The recorded result is the sum of all three element counts.
 * @topic Language
 */
/**
 * @version root
 * @summary One function receiving all three container kinds by const reference, plus a converter from TSet to TArray. The recorded result is the sum of all three element counts.
 * @topic Baseline
 */
UCLASS()
class ACoverageContainerParamMixedActor : AActor
{
	UPROPERTY()
	int ResultSize;

	/**
	 * Sums the element counts of all three container kinds.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs one array, one map and one set
	 * @Return the sum of all three counts
	 * @Param Arr the array parameter
	 * @Param Map the map parameter
	 * @Param Set the set parameter
	 */
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

	/**
	 * Converts a set's elements into an array.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the set to convert
	 * @Return an array holding every set element
	 * @Param InputSet the set to convert
	 */
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

	/**
	 * Exercises both helpers with populated containers.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; ResultSize records the summed counts
	 */
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

	/**
	 * Observe that a locally constructed actor leaves the result unset.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when ResultSize is 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool MixedContainersDefaultEmpty()
	{
		return ResultSize == 0;
	}

	/**
	 * Observe the summed counts after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then ResultSize
	 * @Return true when the result is 7
	 */
	UFUNCTION()
	bool MixedContainersNominal()
	{
		BeginPlay();
		return ResultSize == 7;
	}

	/**
	 * Observe the empty-container boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs three empty containers and the converter
	 * @Return true when the sum is 0 and the converted array is empty
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool MixedContainersEmptyBoundary()
	{
		TArray<int> EmptyArr;
		TMap<int, FString> EmptyMap;
		TSet<int> EmptySet;
		TArray<int> Converted = SetToArray(EmptySet);

		if (ProcessMultipleContainers(EmptyArr, EmptyMap, EmptySet) != 0)
		{
			return false;
		}

		return Converted.Num() == 0;
	}
}
/** @end */
