/**
 * @version v1
 * @summary Empty, single-element, modified, overwritten and deduplicated int containers: an array trimmed by RemoveAt, a map whose key is overwritten, and a set that ignores a duplicate add.
 * @topic Language
 */
/**
 * @version root
 * @summary Empty, single-element, modified, overwritten and deduplicated int containers: an array trimmed by RemoveAt, a map whose key is overwritten, and a set that ignores a duplicate add.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntContainerEdgeActor : AActor
{
	UPROPERTY()
	TArray<int> EmptyArray;

	UPROPERTY()
	TArray<int> SingleElementArray;

	UPROPERTY()
	TArray<int> ModifiedArray;

	UPROPERTY()
	TMap<int, int> EmptyMap;

	UPROPERTY()
	TMap<int, int> SingleEntryMap;

	UPROPERTY()
	TMap<int, int> OverwriteMap;

	UPROPERTY()
	TSet<int> EmptySet;

	UPROPERTY()
	TSet<int> SingleElementSet;

	UPROPERTY()
	TSet<int> DuplicateSet;

	/**
	 * Populates the single, modified, overwritten and deduplicated containers.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the containers hold their edge-case shapes
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Empty containers - no action

		// Single element
		SingleElementArray.Add(42);
		SingleEntryMap.Add(1, 100);
		SingleElementSet.Add(99);

		// Modified array - add then remove
		ModifiedArray.Add(1);
		ModifiedArray.Add(2);
		ModifiedArray.Add(3);
		ModifiedArray.RemoveAt(1);  // Remove middle element

		// Map overwrite
		OverwriteMap.Add(10, 100);
		OverwriteMap.Add(10, 200);  // Overwrite existing key

		// Set with duplicates
		DuplicateSet.Add(5);
		DuplicateSet.Add(10);
		DuplicateSet.Add(5);  // Duplicate - should be ignored
	}

	/**
	 * Observe that a locally constructed actor leaves every container empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all nine containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool IntContainerEdgeDefaultEmpty()
	{
		if (EmptyArray.Num() != 0)
		{
			return false;
		}

		if (SingleElementArray.Num() != 0)
		{
			return false;
		}

		if (ModifiedArray.Num() != 0)
		{
			return false;
		}

		if (EmptyMap.Num() != 0)
		{
			return false;
		}

		if (SingleEntryMap.Num() != 0)
		{
			return false;
		}

		if (OverwriteMap.Num() != 0)
		{
			return false;
		}

		if (EmptySet.Num() != 0)
		{
			return false;
		}

		if (SingleElementSet.Num() != 0)
		{
			return false;
		}

		return DuplicateSet.Num() == 0;
	}

	/**
	 * Observe the edge-case shapes after BeginPlay runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then every container
	 * @Return true when every edge-case shape matches
	 */
	UFUNCTION()
	bool IntContainerEdgeShapesAfterBeginPlay()
	{
		BeginPlay();

		if (EmptyArray.Num() != 0)
		{
			return false;
		}

		if (SingleElementArray.Num() != 1)
		{
			return false;
		}

		if (SingleElementArray[0] != 42)
		{
			return false;
		}

		if (ModifiedArray.Num() != 2)
		{
			return false;
		}

		if (ModifiedArray[0] != 1)
		{
			return false;
		}

		if (EmptyMap.Num() != 0)
		{
			return false;
		}

		if (SingleEntryMap[1] != 100)
		{
			return false;
		}

		if (OverwriteMap[10] != 200)
		{
			return false;
		}

		if (EmptySet.Num() != 0)
		{
			return false;
		}

		if (!SingleElementSet.Contains(99))
		{
			return false;
		}

		if (DuplicateSet.Num() != 2)
		{
			return false;
		}

		if (!DuplicateSet.Contains(5))
		{
			return false;
		}

		return DuplicateSet.Contains(10);
	}
}
/** @end */
