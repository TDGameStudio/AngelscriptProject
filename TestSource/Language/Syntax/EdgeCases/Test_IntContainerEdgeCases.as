// Theme: Language.Syntax.EdgeCases. WorldStory: empty/single/modified int containers.
// C++: AngelscriptCoverageIntPropertyTests.cpp::IntContainerEdgeCases
// sha256=f69db7f5c68c7d9229d41ff4c069ea11c6cc03ca7fc57cd84d9ae8914b2b35d9; lines 1084-1141.
// Oracle after BeginPlay: EmptyArray length 0; SingleElementArray[0]=42 length 1;
// ModifiedArray length 2 with [0]=1 after RemoveAt(1); OverwriteMap key 10 -> 200;
// DuplicateSet ignores the second Add(5).
// Extra: local construct is the empty-container vector before BeginPlay.
// FixtureIsolated. Actor owns container storage.

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

	UFUNCTION()
	bool ObservePopulated()
	{
		return EmptyArray.Num() == 0
			&& SingleElementArray.Num() == 1
			&& SingleElementArray[0] == 42
			&& ModifiedArray.Num() == 2
			&& ModifiedArray[0] == 1
			&& EmptyMap.Num() == 0
			&& SingleEntryMap[1] == 100
			&& OverwriteMap[10] == 200
			&& EmptySet.Num() == 0
			&& SingleElementSet.Contains(99)
			&& DuplicateSet.Num() == 2
			&& DuplicateSet.Contains(5)
			&& DuplicateSet.Contains(10);
	}
}

bool Observe_IntContainerEdge_DefaultEmpty(ACoverageIntContainerEdgeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerEdgeCases setup: required Actor is null");
	}
	return Actor.EmptyArray.Num() == 0 && Actor.SingleElementArray.Num() == 0 && Actor.EmptyMap.Num() == 0 && Actor.EmptySet.Num() == 0;
}

bool Observe_IntContainerEdge_AfterBeginPlay(ACoverageIntContainerEdgeActor Actor)
{
	if (Actor is null)
	{
		throw("Test_IntContainerEdgeCases setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.ObservePopulated();
}
