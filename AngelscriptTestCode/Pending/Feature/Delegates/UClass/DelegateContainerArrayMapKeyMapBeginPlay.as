/**
 * @version v1
 * @summary BeginPlay binds and executes array/map/key-map delegates. ArrayValueResult 2, ArrayInResult 12, bKeyMapOutPreserved / bKeyMapReturnPreserved. Empty array Num 0. Zero-ID item.
 * @topic Feature
 */
/**
 * @version root
 * @summary BeginPlay binds and executes array/map/key-map delegates. ArrayValueResult 2, ArrayInResult 12, bKeyMapOutPreserved / bKeyMapReturnPreserved. Empty array Num 0. Zero-ID item.
 * @topic Baseline
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
	 * @Covers Delegates.DelegateContainerArrayMapKeyMapBeginPlay
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
	 * @Covers Delegates.DelegateContainerArrayMapKeyMapBeginPlay
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

/**
 * Array-by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayValueSignal(TArray<FDelegateContainerStruct> Items);

/**
 * Array const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayInSignal(const TArray<FDelegateContainerStruct>&in Items);

/**
 * Array &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructArrayOutSignal(TArray<FDelegateContainerStruct>&out Items);

/**
 * Array &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayInoutSignal(TArray<FDelegateContainerStruct>&inout Items);

/**
 * Array-return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TArray of items
 */
delegate TArray<FDelegateContainerStruct> FStructArrayReturnSignal();

/**
 * Int-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapValueSignal(TMap<int, FDelegateContainerStruct> Items);

/**
 * Int-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapInSignal(const TMap<int, FDelegateContainerStruct>&in Items);

/**
 * Int-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructMapOutSignal(TMap<int, FDelegateContainerStruct>&out Items);

/**
 * Int-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapInoutSignal(TMap<int, FDelegateContainerStruct>&inout Items);

/**
 * Int-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of items
 */
delegate TMap<int, FDelegateContainerStruct> FStructMapReturnSignal();

/**
 * Struct-key map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapValueSignal(TMap<FDelegateContainerStruct, int> Items);

/**
 * Struct-key map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapInSignal(const TMap<FDelegateContainerStruct, int>&in Items);

/**
 * Struct-key map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructKeyMapOutSignal(TMap<FDelegateContainerStruct, int>&out Items);

/**
 * Struct-key map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapInoutSignal(TMap<FDelegateContainerStruct, int>&inout Items);

/**
 * Struct-key map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of scores
 */
delegate TMap<FDelegateContainerStruct, int> FStructKeyMapReturnSignal();

/**
 * Struct-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapValueSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items);

/**
 * Struct-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapInSignal(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items);

/**
 * Struct-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructStructMapOutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items);

/**
 * Struct-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapInoutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items);

/**
 * Struct-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of structs
 */
delegate TMap<FDelegateContainerStruct, FDelegateContainerStruct> FStructStructMapReturnSignal();

/**
 * Set by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetValueSignal(TSet<FDelegateContainerStruct> Items);

/**
 * Set const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetInSignal(const TSet<FDelegateContainerStruct>&in Items);

/**
 * Set &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructSetOutSignal(TSet<FDelegateContainerStruct>&out Items);

/**
 * Set &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetInoutSignal(TSet<FDelegateContainerStruct>&inout Items);

/**
 * Set return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TSet of items
 */
delegate TSet<FDelegateContainerStruct> FStructSetReturnSignal();

UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	FStructArrayValueSignal ArrayValueSignal;

	UPROPERTY()
	FStructArrayInSignal ArrayInSignal;

	UPROPERTY()
	FStructArrayOutSignal ArrayOutSignal;

	UPROPERTY()
	FStructArrayInoutSignal ArrayInoutSignal;

	UPROPERTY()
	FStructArrayReturnSignal ArrayReturnSignal;

	UPROPERTY()
	FStructMapValueSignal MapValueSignal;

	UPROPERTY()
	FStructMapInSignal MapInSignal;

	UPROPERTY()
	FStructMapOutSignal MapOutSignal;

	UPROPERTY()
	FStructMapInoutSignal MapInoutSignal;

	UPROPERTY()
	FStructMapReturnSignal MapReturnSignal;

	UPROPERTY()
	FStructKeyMapValueSignal KeyMapValueSignal;

	UPROPERTY()
	FStructKeyMapInSignal KeyMapInSignal;

	UPROPERTY()
	FStructKeyMapOutSignal KeyMapOutSignal;

	UPROPERTY()
	FStructKeyMapInoutSignal KeyMapInoutSignal;

	UPROPERTY()
	FStructKeyMapReturnSignal KeyMapReturnSignal;

	UPROPERTY()
	FStructStructMapValueSignal StructMapValueSignal;

	UPROPERTY()
	FStructStructMapInSignal StructMapInSignal;

	UPROPERTY()
	FStructStructMapOutSignal StructMapOutSignal;

	UPROPERTY()
	FStructStructMapInoutSignal StructMapInoutSignal;

	UPROPERTY()
	FStructStructMapReturnSignal StructMapReturnSignal;

	UPROPERTY()
	FStructSetValueSignal SetValueSignal;

	UPROPERTY()
	FStructSetInSignal SetInSignal;

	UPROPERTY()
	FStructSetOutSignal SetOutSignal;

	UPROPERTY()
	FStructSetInoutSignal SetInoutSignal;

	UPROPERTY()
	FStructSetReturnSignal SetReturnSignal;

	UPROPERTY()
	int ArrayValueResult = 0;

	UPROPERTY()
	int ArrayInResult = 0;

	UPROPERTY()
	int ArrayInoutResult = 0;

	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayOutResult;

	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayInoutResultItems;

	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayReturnResult;

	UPROPERTY()
	int MapValueResult = 0;

	UPROPERTY()
	int MapInResult = 0;

	UPROPERTY()
	int MapInoutResult = 0;

	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapOutResult;

	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapInoutResultItems;

	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapReturnResult;

	UPROPERTY()
	int KeyMapValueResult = 0;

	UPROPERTY()
	int KeyMapInResult = 0;

	UPROPERTY()
	int KeyMapInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapOutResult;

	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapInoutResultItems;

	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapReturnResult;

	UPROPERTY()
	bool bKeyMapOutPreserved = false;

	UPROPERTY()
	bool bKeyMapReturnPreserved = false;

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
	 * @Covers Delegates.DelegateContainerArrayMapKeyMapBeginPlay
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
	 * Count a struct-to-struct map by value.
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
		return Items.Num();
	}

	/**
	 * Count a const struct-to-struct map as &in.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructMapIn(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items)
	{
		return Items.Num();
	}

	/**
	 * Fill an &out struct-to-struct map (no-op in this fragment).
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
	}

	/**
	 * Count an &inout struct-to-struct map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructMapInout(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items)
	{
		return Items.Num();
	}

	/**
	 * Return an empty struct-to-struct map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return an empty map
	 */
	UFUNCTION()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> HandleStructMapReturn()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		return Items;
	}

	/**
	 * Count a set by value.
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
		return Items.Num();
	}

	/**
	 * Count a const set as &in.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received as const TSet<FDelegateContainerStruct>&in
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleSetIn(const TSet<FDelegateContainerStruct>&in Items)
	{
		return Items.Num();
	}

	/**
	 * Fill an &out set (no-op in this fragment).
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
	}

	/**
	 * Count an &inout set.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Set received as TSet<FDelegateContainerStruct>&inout
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleSetInout(TSet<FDelegateContainerStruct>&inout Items)
	{
		return Items.Num();
	}

	/**
	 * Return an empty set.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return an empty set
	 */
	UFUNCTION()
	TSet<FDelegateContainerStruct> HandleSetReturn()
	{
		TSet<FDelegateContainerStruct> Items;
		return Items;
	}

	/**
	 * WorldStory: BeginPlay binds and executes array/map/key-map delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ArrayValueResult 2, ArrayInResult 12, bKeyMapOutPreserved / bKeyMapReturnPreserved
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrayValueSignal.BindUFunction(this, n"HandleArrayValue");
		ArrayInSignal.BindUFunction(this, n"HandleArrayIn");
		ArrayOutSignal.BindUFunction(this, n"HandleArrayOut");
		ArrayInoutSignal.BindUFunction(this, n"HandleArrayInout");
		ArrayReturnSignal.BindUFunction(this, n"HandleArrayReturn");

		MapValueSignal.BindUFunction(this, n"HandleMapValue");
		MapInSignal.BindUFunction(this, n"HandleMapIn");
		MapOutSignal.BindUFunction(this, n"HandleMapOut");
		MapInoutSignal.BindUFunction(this, n"HandleMapInout");
		MapReturnSignal.BindUFunction(this, n"HandleMapReturn");

		KeyMapValueSignal.BindUFunction(this, n"HandleKeyMapValue");
		KeyMapInSignal.BindUFunction(this, n"HandleKeyMapIn");
		KeyMapOutSignal.BindUFunction(this, n"HandleKeyMapOut");
		KeyMapInoutSignal.BindUFunction(this, n"HandleKeyMapInout");
		KeyMapReturnSignal.BindUFunction(this, n"HandleKeyMapReturn");

		StructMapValueSignal.BindUFunction(this, n"HandleStructMapValue");
		StructMapInSignal.BindUFunction(this, n"HandleStructMapIn");
		StructMapOutSignal.BindUFunction(this, n"HandleStructMapOut");
		StructMapInoutSignal.BindUFunction(this, n"HandleStructMapInout");
		StructMapReturnSignal.BindUFunction(this, n"HandleStructMapReturn");

		SetValueSignal.BindUFunction(this, n"HandleSetValue");
		SetInSignal.BindUFunction(this, n"HandleSetIn");
		SetOutSignal.BindUFunction(this, n"HandleSetOut");
		SetInoutSignal.BindUFunction(this, n"HandleSetInout");
		SetReturnSignal.BindUFunction(this, n"HandleSetReturn");

		TArray<FDelegateContainerStruct> ArrayValueItems;
		ArrayValueItems.Add(MakeItem(10, n"ArrayValueA"));
		ArrayValueItems.Add(MakeItem(11, n"ArrayValueB"));
		ArrayValueResult = ArrayValueSignal.Execute(ArrayValueItems);

		TArray<FDelegateContainerStruct> ArrayInItems;
		ArrayInItems.Add(MakeItem(12, n"ArrayInA"));
		ArrayInItems.Add(MakeItem(13, n"ArrayInB"));
		ArrayInResult = ArrayInSignal.Execute(ArrayInItems);

		ArrayOutSignal.Execute(ArrayOutResult);

		ArrayInoutResultItems.Add(MakeItem(10, n"ArrayInoutA"));
		ArrayInoutResult = ArrayInoutSignal.Execute(ArrayInoutResultItems);

		ArrayReturnResult = ArrayReturnSignal.Execute();

		TMap<int, FDelegateContainerStruct> MapValueItems;
		MapValueItems.Add(10, MakeItem(10, n"MapValueA"));
		MapValueItems.Add(11, MakeItem(11, n"MapValueB"));
		MapValueResult = MapValueSignal.Execute(MapValueItems);

		TMap<int, FDelegateContainerStruct> MapInItems;
		MapInItems.Add(12, MakeItem(12, n"MapInA"));
		MapInItems.Add(13, MakeItem(13, n"MapInB"));
		MapInResult = MapInSignal.Execute(MapInItems);

		MapOutSignal.Execute(MapOutResult);

		MapInoutResultItems.Add(10, MakeItem(10, n"MapInoutA"));
		MapInoutResult = MapInoutSignal.Execute(MapInoutResultItems);

		MapReturnResult = MapReturnSignal.Execute();

		TMap<FDelegateContainerStruct, int> KeyMapValueItems;
		KeyMapValueItems.Add(MakeItem(40, n"KeyMapValueA"), 140);
		KeyMapValueItems.Add(MakeItem(41, n"KeyMapValueB"), 141);
		KeyMapValueResult = KeyMapValueSignal.Execute(KeyMapValueItems);

		TMap<FDelegateContainerStruct, int> KeyMapInItems;
		KeyMapInItems.Add(MakeItem(42, n"KeyMapInA"), 142);
		KeyMapInItems.Add(MakeItem(43, n"KeyMapInB"), 143);
		KeyMapInResult = KeyMapInSignal.Execute(KeyMapInItems);

		KeyMapOutSignal.Execute(KeyMapOutResult);
		int KeyMapOutFound = 0;
		bKeyMapOutPreserved =
			KeyMapOutResult.Find(MakeItem(51, n"KeyMapOutB"), KeyMapOutFound)
			&& KeyMapOutFound == 151;

		KeyMapInoutResultItems.Add(MakeItem(52, n"KeyMapInoutA"), 152);
		KeyMapInoutResult = KeyMapInoutSignal.Execute(KeyMapInoutResultItems);

		KeyMapReturnResult = KeyMapReturnSignal.Execute();
		int KeyMapReturnFound = 0;
		bKeyMapReturnPreserved =
			KeyMapReturnResult.Find(MakeItem(55, n"KeyMapReturnB"), KeyMapReturnFound)
			&& KeyMapReturnFound == 155;
	}

	/**
	 * Observe the default ArrayValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ArrayValueResult
	 */
	UFUNCTION()
	int ArrayValueResultDefaultZero()
	{
		return ArrayValueResult;
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
/** @end */
