// Theme: Containers.TMap. WorldStory: empty Contains/Remove and single-entry Empty.
// C++ VerifyByPath: EmptySize=0, ContainsResult=0, bRemovedFromEmpty false,
// SingleEntrySize=1, AfterSingleRemoveSize=0. Extra: empty map is the default vector.
// FixtureIsolated.

UCLASS()
class ACoverageTMapEdgeCasesActor : AActor
{
	UPROPERTY()
	int EmptySize;

	UPROPERTY()
	int ContainsResult;

	UPROPERTY()
	int SingleEntrySize;

	UPROPERTY()
	bool bRemovedFromEmpty;

	UPROPERTY()
	int AfterSingleRemoveSize;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== TMap Edge Cases Test ===");

		// Test empty map operations
		TMap<int, FString> EmptyMap;
		Print("Empty map size: " + EmptyMap.Num());
		EmptySize = EmptyMap.Num();

		bool HasKey = EmptyMap.Contains(5);
		Print("Contains(5) in empty map: " + HasKey);
		ContainsResult = HasKey ? 1 : 0;

		// Remove from empty map (should not crash)
		bool bRemoved = EmptyMap.Remove(5);
		Print("Remove(5) from empty map returned: " + bRemoved);
		bRemovedFromEmpty = bRemoved;

		// Test single entry map
		TMap<int, FString> SingleMap;
		SingleMap.Add(42, "Answer");
		Print("Single entry map size: " + SingleMap.Num());
		SingleEntrySize = SingleMap.Num();

		// Remove the only entry
		SingleMap.Remove(42);
		Print("After removing only entry: " + SingleMap.Num());
		AfterSingleRemoveSize = SingleMap.Num();
	}
}
