/**
 * Array/map/key-map handler round-trips. HandleArrayValue Num 2 preserves ID
 * 11. HandleArrayIn 12. Empty array Num 0. Zero-ID item Hash 0+Tag.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateContainerArrayMapHandlerRoundTrip
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateContainerArrayMapHandlerRoundTrip
 * @Provenance Theme: Feature.Delegates. Positive block 4: array/map/key-map handler round-trips.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5914-6049.
 * @Provenance Isolation=none: wrap MakeItem and handlers with FDelegateContainerStruct and the flags
 * @Provenance those handlers write. Oracle: HandleArrayValue Num 2 preserves ID 11; HandleArrayIn 12.
 * @Provenance Extra: empty array Num 0; zero-ID item Hash 0+Tag. DefaultSafe.
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
	 * @Covers Delegates.DelegateContainerArrayMapHandlerRoundTrip
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
	 * @Covers Delegates.DelegateContainerArrayMapHandlerRoundTrip
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
	bool bArrayValuePreserved = false;

	UPROPERTY()
	bool bArrayInPreserved = false;

	UPROPERTY()
	bool bMapValuePreserved = false;

	UPROPERTY()
	bool bMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapValuePreserved = false;

	UPROPERTY()
	bool bKeyMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapInoutPreserved = false;

	/**
	 * Build a container item from an id and tag.
	 *
	 * @Covers Delegates.DelegateContainerArrayMapHandlerRoundTrip
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
	 * Count an array by value and record Items[1] ID 11.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Array received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleArrayValue(TArray<FDelegateContainerStruct> Items)
	{
		bArrayValuePreserved = Items.Num() == 2 && Items[1].ID == 11 && Items[1].Tag == n"ArrayValueB";
		return Items.Num();
	}

	/**
	 * Count a const array as &in and record Items[0] ID 12.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Array received as const TArray<FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num() + 10
	 */
	UFUNCTION()
	int HandleArrayIn(const TArray<FDelegateContainerStruct>&in Items)
	{
		bArrayInPreserved = Items.Num() == 2 && Items[0].ID == 12 && Items[0].Tag == n"ArrayInA";
		return Items.Num() + 10;
	}

	/**
	 * Fill an &out array with two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Array received as TArray<FDelegateContainerStruct>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleArrayOut(TArray<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"ArrayOutA"));
		Items.Add(MakeItem(21, n"ArrayOutB"));
	}

	/**
	 * Mutate an &inout array and return Num + first ID.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Array received as TArray<FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Items[0].ID
	 */
	UFUNCTION()
	int HandleArrayInout(TArray<FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct First = Items[0];
		First.ID += 100;
		First.Tag = n"ArrayInoutMutated";
		Items[0] = First;
		Items.Add(MakeItem(22, n"ArrayInoutAdded"));
		return Items.Num() + Items[0].ID;
	}

	/**
	 * Return an array of two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return IDs 30 and 31
	 */
	UFUNCTION()
	TArray<FDelegateContainerStruct> HandleArrayReturn()
	{
		TArray<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"ArrayReturnA"));
		Items.Add(MakeItem(31, n"ArrayReturnB"));
		return Items;
	}

	/**
	 * Count a map by value and record Find(11) ID 11.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleMapValue(TMap<int, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bMapValuePreserved = Items.Find(11, Found) && Found.ID == 11 && Found.Tag == n"MapValueB";
		return Items.Num();
	}

	/**
	 * Count a const map as &in and record Find(12) ID 12.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<int, FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num() + 20
	 */
	UFUNCTION()
	int HandleMapIn(const TMap<int, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bMapInPreserved = Items.Find(12, Found) && Found.ID == 12 && Found.Tag == n"MapInA";
		return Items.Num() + 20;
	}

	/**
	 * Fill an &out map with two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<int, FDelegateContainerStruct>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleMapOut(TMap<int, FDelegateContainerStruct>&out Items)
	{
		Items.Add(20, MakeItem(20, n"MapOutA"));
		Items.Add(21, MakeItem(21, n"MapOutB"));
	}

	/**
	 * Mutate an &inout map and return Num + key 10 ID.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<int, FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Items[10].ID
	 */
	UFUNCTION()
	int HandleMapInout(TMap<int, FDelegateContainerStruct>&inout Items)
	{
		Items[10] = MakeItem(110, n"MapInoutMutated");
		Items.Add(22, MakeItem(22, n"MapInoutAdded"));
		return Items.Num() + Items[10].ID;
	}

	/**
	 * Return a map of two items.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 30 and 31
	 */
	UFUNCTION()
	TMap<int, FDelegateContainerStruct> HandleMapReturn()
	{
		TMap<int, FDelegateContainerStruct> Items;
		Items.Add(30, MakeItem(30, n"MapReturnA"));
		Items.Add(31, MakeItem(31, n"MapReturnB"));
		return Items;
	}

	/**
	 * Count a struct-key map by value and record Find key 41 score 141.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleKeyMapValue(TMap<FDelegateContainerStruct, int> Items)
	{
		int Found = 0;
		bKeyMapValuePreserved = Items.Find(MakeItem(41, n"KeyMapValueB"), Found) && Found == 141;
		return Items.Num();
	}

	/**
	 * Count a const struct-key map as &in and record Find key 42 score 142.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateContainerStruct, int>&in
	 * @Inputs Items
	 * @Return Items.Num() + 40
	 */
	UFUNCTION()
	int HandleKeyMapIn(const TMap<FDelegateContainerStruct, int>&in Items)
	{
		int Found = 0;
		bKeyMapInPreserved = Items.Find(MakeItem(42, n"KeyMapInA"), Found) && Found == 142;
		return Items.Num() + 40;
	}

	/**
	 * Fill an &out struct-key map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateContainerStruct, int>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleKeyMapOut(TMap<FDelegateContainerStruct, int>&out Items)
	{
		Items.Add(MakeItem(50, n"KeyMapOutA"), 150);
		Items.Add(MakeItem(51, n"KeyMapOutB"), 151);
	}

	/**
	 * Mutate an &inout struct-key map, rewriting key 52 to 252.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateContainerStruct, int>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Found
	 */
	UFUNCTION()
	int HandleKeyMapInout(TMap<FDelegateContainerStruct, int>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(52, n"KeyMapInoutA");
		Items.Remove(Existing);
		Items.Add(Existing, 252);
		Items.Add(MakeItem(53, n"KeyMapInoutB"), 153);

		int Found = 0;
		bKeyMapInoutPreserved = Items.Find(Existing, Found) && Found == 252;
		return Items.Num() + Found;
	}

	/**
	 * Return a struct-key map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 54 and 55
	 */
	UFUNCTION()
	TMap<FDelegateContainerStruct, int> HandleKeyMapReturn()
	{
		TMap<FDelegateContainerStruct, int> Items;
		Items.Add(MakeItem(54, n"KeyMapReturnA"), 154);
		Items.Add(MakeItem(55, n"KeyMapReturnB"), 155);
		return Items;
	}

	/**
	 * Observe empty array Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty array
	 * @Return 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	int EmptyArrayDefaultNum()
	{
		TArray<FDelegateContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe MakeItem of ID 0 empty Tag.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs ID 0 Tag empty
	 * @Return 0
	 * @Boundary zero-ID item
	 */
	UFUNCTION()
	int MakeItemZeroBoundary()
	{
		FDelegateContainerStruct Item = MakeItem(0, n"");
		return Item.ID;
	}

	/**
	 * Observe that mutating an item copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original ID 11 and a zeroed copy
	 * @Return true when Original.ID stays 11
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ItemCopyIndependence()
	{
		FDelegateContainerStruct Original;
		Original.ID = 11;
		Original.Tag = n"ArrayValueB";
		FDelegateContainerStruct Copy = Original;
		Copy.ID = 0;
		if (Original.ID != 11)
		{
			return false;
		}
		return Copy.ID == 0;
	}
}
