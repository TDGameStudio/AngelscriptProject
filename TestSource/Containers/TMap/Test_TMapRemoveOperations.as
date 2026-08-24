// Theme: Containers.TMap. WorldStory: Remove existing key then Empty.
// C++ VerifyByPath: InitialSize=5, bRemovedExisting true, bContainsRemovedKey false,
// AfterRemoveSize=4, AfterEmptySize=0. Extra: AfterEmptySize is the empty boundary.
// FixtureIsolated.

UCLASS()
class ACoverageTMapRemoveActor : AActor
{
	UPROPERTY()
	int InitialSize;

	UPROPERTY()
	int AfterRemoveSize;

	UPROPERTY()
	int AfterEmptySize;

	UPROPERTY()
	bool bRemovedExisting;

	UPROPERTY()
	bool bContainsRemovedKey;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== TMap Remove Operations Test ===");

		TMap<int, FString> Items;
		Items.Add(1, "One");
		Items.Add(2, "Two");
		Items.Add(3, "Three");
		Items.Add(4, "Four");
		Items.Add(5, "Five");

		Print("Initial map size: " + Items.Num());
		InitialSize = Items.Num();

		// Test Remove - returns whether the key was removed.
		bool bRemoved = Items.Remove(3);
		Print("Removed key 3: " + bRemoved);
		Print("Size after Remove: " + Items.Num());
		bRemovedExisting = bRemoved;
		AfterRemoveSize = Items.Num();

		// Verify key no longer exists
		bool HasThree = Items.Contains(3);
		Print("Contains(3) after Remove: " + HasThree);
		bContainsRemovedKey = HasThree;

		// Test Empty
		Items.Empty();
		Print("Size after Empty: " + Items.Num());
		AfterEmptySize = Items.Num();
	}
}
