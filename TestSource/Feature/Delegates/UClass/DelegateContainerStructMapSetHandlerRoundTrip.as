/**
 * Struct-map and set handler round-trips. HandleStructMapValue preserves ID
 * 161. HandleSetValue Contains SetValueB. Empty TMap/TSet Num 0. Zero-ID key
 * miss.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateContainerStructMapSetHandlerRoundTrip
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateContainerStructMapSetHandlerRoundTrip
 * @Provenance Theme: Feature.Delegates. Positive block 5: struct-map and set handler round-trips.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 6050-6143.
 * @Provenance Isolation=none: wrap HandleStructMap* / HandleSet* with FDelegateContainerStruct and flags.
 * @Provenance Oracle: HandleStructMapValue preserves ID 161; HandleSetValue Contains SetValueB.
 * @Provenance Extra: empty TMap/TSet Num 0; zero-ID key miss. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FDelegateContainerStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two items by ID and Tag.
	 *
	 * @Covers Delegates.DelegateContainerStructMapSetHandlerRoundTrip
	 * @Inputs another FDelegateContainerStruct
	 * @Return true when ID and Tag match
	 * @Param Other the other item
	 */
	bool opEquals(const FDelegateContainerStruct&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 977 plus Tag.GetHash().
	 *
	 * @Covers Delegates.DelegateContainerStructMapSetHandlerRoundTrip
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	bool bStructMapValuePreserved = false;

	UPROPERTY()
	bool bStructMapInPreserved = false;

	UPROPERTY()
	bool bStructMapInoutPreserved = false;

	UPROPERTY()
	bool bSetValuePreserved = false;

	UPROPERTY()
	bool bSetInPreserved = false;

	/**
	 * Build a container item from an id and tag.
	 *
	 * @Covers Delegates.DelegateContainerStructMapSetHandlerRoundTrip
	 * @Inputs ID and Tag
	 * @Return an item holding those fields
	 * @Param ID the item id
	 * @Param Tag the item tag
	 */
	FDelegateContainerStruct MakeItem(int ID, FName Tag)
	{
		FDelegateContainerStruct Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	/**
	 * Count a struct-to-struct map by value and record Find key 61 ID 161.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructMapValue(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bStructMapValuePreserved =
			Items.Find(MakeItem(61, n"StructMapValueKeyB"), Found)
			&& Found.ID == 161
			&& Found.Tag == n"StructMapValueValueB";
		return Items.Num();
	}

	/**
	 * Count a const struct-to-struct map as &in and record Find key 62 ID 162.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num() + 60
	 */
	UFUNCTION()
	int HandleStructMapIn(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bStructMapInPreserved =
			Items.Find(MakeItem(62, n"StructMapInKeyA"), Found)
			&& Found.ID == 162
			&& Found.Tag == n"StructMapInValueA";
		return Items.Num() + 60;
	}

	/**
	 * Fill an &out struct-to-struct map with two entries.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructMapOut(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(70, n"StructMapOutKeyA"), MakeItem(170, n"StructMapOutValueA"));
		Items.Add(MakeItem(71, n"StructMapOutKeyB"), MakeItem(171, n"StructMapOutValueB"));
	}

	/**
	 * Mutate an &inout struct-to-struct map, rewriting key 72 to ID 272.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Found.ID
	 */
	UFUNCTION()
	int HandleStructMapInout(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(72, n"StructMapInoutKeyA");
		Items.Remove(Existing);
		Items.Add(Existing, MakeItem(272, n"StructMapInoutMutated"));
		Items.Add(MakeItem(73, n"StructMapInoutKeyB"), MakeItem(173, n"StructMapInoutAdded"));

		FDelegateContainerStruct Found;
		bStructMapInoutPreserved =
			Items.Find(Existing, Found)
			&& Found.ID == 272
			&& Found.Tag == n"StructMapInoutMutated";
		return Items.Num() + Found.ID;
	}

	/**
	 * Return a struct-to-struct map of two entries.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 74 and 75
	 */
	UFUNCTION()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> HandleStructMapReturn()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		Items.Add(MakeItem(74, n"StructMapReturnKeyA"), MakeItem(174, n"StructMapReturnValueA"));
		Items.Add(MakeItem(75, n"StructMapReturnKeyB"), MakeItem(175, n"StructMapReturnValueB"));
		return Items;
	}

	/**
	 * Count a set by value and record Contains SetValueB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleSetValue(TSet<FDelegateContainerStruct> Items)
	{
		bSetValuePreserved = Items.Contains(MakeItem(11, n"SetValueB"));
		return Items.Num();
	}

	/**
	 * Count a const set as &in and record Contains SetInA.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received as const TSet<FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleSetIn(const TSet<FDelegateContainerStruct>&in Items)
	{
		bSetInPreserved = Items.Contains(MakeItem(12, n"SetInA"));
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out set with two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received as TSet<FDelegateContainerStruct>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleSetOut(TSet<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"SetOutA"));
		Items.Add(MakeItem(21, n"SetOutB"));
	}

	/**
	 * Mutate an &inout set by removing SetInoutA and adding SetInoutAdded.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received as TSet<FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 40
	 */
	UFUNCTION()
	int HandleSetInout(TSet<FDelegateContainerStruct>&inout Items)
	{
		Items.Remove(MakeItem(10, n"SetInoutA"));
		Items.Add(MakeItem(22, n"SetInoutAdded"));
		return Items.Num() + 40;
	}

	/**
	 * Return a set of two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return IDs 30 and 31
	 */
	UFUNCTION()
	TSet<FDelegateContainerStruct> HandleSetReturn()
	{
		TSet<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"SetReturnA"));
		Items.Add(MakeItem(31, n"SetReturnB"));
		return Items;
	}

	/**
	 * Observe empty struct-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyMapDefaultNum()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe empty set Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty set
	 * @Return 0
	 * @Boundary empty set
	 */
	UFUNCTION()
	int EmptySetDefaultNum()
	{
		TSet<FDelegateContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe Find of a zero-ID key on an empty map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map and a default key
	 * @Return true when Find misses and Found stays 0
	 * @Boundary zero-ID key miss
	 */
	UFUNCTION()
	bool ZeroKeyMissingBoundary()
	{
		TMap<FDelegateContainerStruct, int> Items;
		FDelegateContainerStruct Zero;
		int Found = 0;
		if (Items.Find(Zero, Found))
		{
			return false;
		}
		return Found == 0;
	}
}
