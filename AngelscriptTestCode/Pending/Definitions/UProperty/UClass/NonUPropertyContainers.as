/**
 * @version v1
 * @summary Local TArray/TMap that are not UPROPERTY still write reflected results. C++ verifies LocalArrayResult and TempMapResult by path, so those names are kept. The observers cover empty local array/map Num 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Local TArray/TMap that are not UPROPERTY still write reflected results. C++ verifies LocalArrayResult and TempMapResult by path, so those names are kept. The observers cover empty local array/map Num 0.
 * @topic Baseline
 */
UCLASS()
class ACoverageContainerNonUPropActor : AActor
{
	UPROPERTY()
	int LocalArrayResult;

	UPROPERTY()
	int TempMapResult;

	/**
	 * Fill a local TArray and publish its Num through LocalArrayResult.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NonUPropertyContainers
	 * @Inputs a local TArray with three ints
	 * @Return LocalArrayResult == 3
	 */
	void ProcessLocalArray()
	{
		Print("=== ProcessLocalArray ===");
		TArray<int> LocalArray;
		LocalArray.Add(100);
		LocalArray.Add(200);
		LocalArray.Add(300);
		Print("Local array size: " + LocalArray.Num());
		LocalArrayResult = LocalArray.Num();
	}

	/**
	 * Fill a local TMap and publish its Num through TempMapResult.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NonUPropertyContainers
	 * @Inputs a local TMap with two entries
	 * @Return TempMapResult == 2
	 */
	void UseTempMap()
	{
		Print("=== UseTempMap ===");
		TMap<int, int> TempMap;
		TempMap.Add(1, 10);
		TempMap.Add(2, 20);
		TempMapResult = TempMap.Num();
		Print("Temp map size: " + TempMapResult);
	}

	/**
	 * WorldStory: run the local-container helpers after play begins.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.NonUPropertyContainers
	 * @Inputs none
	 * @Return LocalArrayResult 3 and TempMapResult 2
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== Non-UPROPERTY Containers Test ===");
		ProcessLocalArray();
		UseTempMap();
	}

	/**
	 * Observe that an empty local array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NonUPropertyContainers
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyLocalArrayNum()
	{
		TArray<int> LocalArray;
		return LocalArray.Num();
	}

	/**
	 * Observe that an empty temp map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NonUPropertyContainers
	 * @Inputs a default-constructed TMap<int, int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EmptyTempMapNum()
	{
		TMap<int, int> TempMap;
		return TempMap.Num();
	}
}
/** @end */
