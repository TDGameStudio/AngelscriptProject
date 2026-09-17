/**
 * @version v1
 * @summary BeginPlay struct-map and set executes. StructMapValueResult 2, bStructMapOutPreserved / bStructMapReturnPreserved, SetValueResult 2. Empty TMap/TSet Num 0. Zero-ID miss.
 * @topic Feature
 */
/**
 * @version root
 * @summary BeginPlay struct-map and set executes. StructMapValueResult 2, bStructMapOutPreserved / bStructMapReturnPreserved, SetValueResult 2. Empty TMap/TSet Num 0. Zero-ID miss.
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
	 * @Covers Delegates.DelegateContainerStructMapSetBeginPlay
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
	 * @Covers Delegates.DelegateContainerStructMapSetBeginPlay
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

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
	int StructMapValueResult = 0;

	UPROPERTY()
	int StructMapInResult = 0;

	UPROPERTY()
	int StructMapInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapOutResult;

	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapInoutResultItems;

	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapReturnResult;

	UPROPERTY()
	int SetValueResult = 0;

	UPROPERTY()
	int SetInResult = 0;

	UPROPERTY()
	int SetInoutResult = 0;

	UPROPERTY()
	TSet<FDelegateContainerStruct> SetOutResult;

	UPROPERTY()
	TSet<FDelegateContainerStruct> SetInoutResultItems;

	UPROPERTY()
	TSet<FDelegateContainerStruct> SetReturnResult;

	UPROPERTY()
	bool bStructMapOutPreserved = false;

	UPROPERTY()
	bool bStructMapReturnPreserved = false;

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
	 * @Covers Delegates.DelegateContainerStructMapSetBeginPlay
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
	 * WorldStory: BeginPlay binds and executes struct-map and set delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return StructMapValueResult 2, SetValueResult 2, out/return preserved
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
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

		TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapValueItems;
		StructMapValueItems.Add(MakeItem(60, n"StructMapValueKeyA"), MakeItem(160, n"StructMapValueValueA"));
		StructMapValueItems.Add(MakeItem(61, n"StructMapValueKeyB"), MakeItem(161, n"StructMapValueValueB"));
		StructMapValueResult = StructMapValueSignal.Execute(StructMapValueItems);

		TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapInItems;
		StructMapInItems.Add(MakeItem(62, n"StructMapInKeyA"), MakeItem(162, n"StructMapInValueA"));
		StructMapInItems.Add(MakeItem(63, n"StructMapInKeyB"), MakeItem(163, n"StructMapInValueB"));
		StructMapInResult = StructMapInSignal.Execute(StructMapInItems);

		StructMapOutSignal.Execute(StructMapOutResult);
		FDelegateContainerStruct StructMapOutFound;
		bStructMapOutPreserved =
			StructMapOutResult.Find(MakeItem(71, n"StructMapOutKeyB"), StructMapOutFound)
			&& StructMapOutFound.ID == 171
			&& StructMapOutFound.Tag == n"StructMapOutValueB";

		StructMapInoutResultItems.Add(MakeItem(72, n"StructMapInoutKeyA"), MakeItem(172, n"StructMapInoutOriginal"));
		StructMapInoutResult = StructMapInoutSignal.Execute(StructMapInoutResultItems);

		StructMapReturnResult = StructMapReturnSignal.Execute();
		FDelegateContainerStruct StructMapReturnFound;
		bStructMapReturnPreserved =
			StructMapReturnResult.Find(MakeItem(75, n"StructMapReturnKeyB"), StructMapReturnFound)
			&& StructMapReturnFound.ID == 175
			&& StructMapReturnFound.Tag == n"StructMapReturnValueB";

		TSet<FDelegateContainerStruct> SetValueItems;
		SetValueItems.Add(MakeItem(10, n"SetValueA"));
		SetValueItems.Add(MakeItem(11, n"SetValueB"));
		SetValueResult = SetValueSignal.Execute(SetValueItems);

		TSet<FDelegateContainerStruct> SetInItems;
		SetInItems.Add(MakeItem(12, n"SetInA"));
		SetInItems.Add(MakeItem(13, n"SetInB"));
		SetInResult = SetInSignal.Execute(SetInItems);

		SetOutSignal.Execute(SetOutResult);

		SetInoutResultItems.Add(MakeItem(10, n"SetInoutA"));
		SetInoutResult = SetInoutSignal.Execute(SetInoutResultItems);

		SetReturnResult = SetReturnSignal.Execute();
	}

	/**
	 * Observe the default StructMapValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default StructMapValueResult
	 */
	UFUNCTION()
	int StructMapValueResultDefaultZero()
	{
		return StructMapValueResult;
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
	 * Observe that mutating an item copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original ID 161 and a zeroed copy
	 * @Return true when Original.ID stays 161
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ItemCopyIndependence()
	{
		FDelegateContainerStruct Original;
		Original.ID = 161;
		Original.Tag = n"StructMapValueValueB";
		FDelegateContainerStruct Copy = Original;
		Copy.ID = 0;
		if (Original.ID != 161)
		{
			return false;
		}
		return Copy.ID == 0;
	}
}
/** @end */
