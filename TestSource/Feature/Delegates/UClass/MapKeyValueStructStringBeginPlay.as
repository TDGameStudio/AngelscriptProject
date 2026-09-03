/**
 * BeginPlay struct-string map executes. StructStringValueResult 2.
 * StructStringOutB preserved. Empty TMap Num 0. Zero-key miss.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueStructStringBeginPlay
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueStructStringBeginPlay
 * @Provenance Theme: Feature.Delegates. Positive block 12: BeginPlay struct-string map executes.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8221-8253.
 * @Provenance Isolation=none: wrap the BeginPlay statements with struct-string signals, MakeKey, handlers.
 * @Provenance Oracle: StructStringValueResult 2; StructStringOutB preserved. Extra: empty TMap Num 0;
 * @Provenance zero-key miss. DefaultSafe. Keep StructStringValueSignal.
 */

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.MapKeyValueStructStringBeginPlay
	 * @Inputs another FDelegateKeyValueMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FDelegateKeyValueMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 929 plus Tag.GetHash().
	 *
	 * @Covers Delegates.MapKeyValueStructStringBeginPlay
	 * @Inputs none
	 * @Return uint32(ID * 929) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

/**
 * Struct-to-string map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapValueSignal(TMap<FDelegateKeyValueMapKey, FString> Items);

/**
 * Struct-to-string map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapInSignal(const TMap<FDelegateKeyValueMapKey, FString>&in Items);

/**
 * Struct-to-string map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructStringMapOutSignal(TMap<FDelegateKeyValueMapKey, FString>&out Items);

/**
 * Struct-to-string map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStringMapInoutSignal(TMap<FDelegateKeyValueMapKey, FString>&inout Items);

/**
 * Struct-to-string map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of strings
 */
delegate TMap<FDelegateKeyValueMapKey, FString> FStructStringMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FStructStringMapValueSignal StructStringValueSignal;

	UPROPERTY()
	FStructStringMapInSignal StructStringInSignal;

	UPROPERTY()
	FStructStringMapOutSignal StructStringOutSignal;

	UPROPERTY()
	FStructStringMapInoutSignal StructStringInoutSignal;

	UPROPERTY()
	FStructStringMapReturnSignal StructStringReturnSignal;

	UPROPERTY()
	int StructStringValueResult = 0;

	UPROPERTY()
	int StructStringInResult = 0;

	UPROPERTY()
	int StructStringInoutResult = 0;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringOutResult;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringInoutResultItems;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringReturnResult;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringOutPreserved = false;

	UPROPERTY()
	bool StructStringInoutPreserved = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers Delegates.MapKeyValueStructStringBeginPlay
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Count a struct-to-string map by value and record Find StructStringValueB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructStringValue(TMap<FDelegateKeyValueMapKey, FString> Items)
	{
		FString Found;
		StructStringValuePreserved = Items.Find(MakeKey(301, n"StructStringValueB"), Found) && Found == "StructStringValueB";
		return Items.Num();
	}

	/**
	 * Count a const struct-to-string map as &in and record Find StructStringInB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateKeyValueMapKey, FString>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleStructStringIn(const TMap<FDelegateKeyValueMapKey, FString>&in Items)
	{
		FString Found;
		StructStringInPreserved = Items.Find(MakeKey(311, n"StructStringInB"), Found) && Found == "StructStringInB";
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out struct-to-string map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, FString>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructStringOut(TMap<FDelegateKeyValueMapKey, FString>&out Items)
	{
		Items.Add(MakeKey(320, n"StructStringOutA"), "StructStringOutA");
		Items.Add(MakeKey(321, n"StructStringOutB"), "StructStringOutB");
	}

	/**
	 * Mutate an &inout struct-to-string map, rewriting key 330.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, FString>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 40
	 */
	UFUNCTION()
	int HandleStructStringInout(TMap<FDelegateKeyValueMapKey, FString>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(330, n"StructStringInoutA");
		FString Found;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, "StructStringInoutMutated");
		}
		Items.Add(MakeKey(331, n"StructStringInoutB"), "StructStringInoutAdded");
		StructStringInoutResultItems = Items;
		FString Mutated;
		StructStringInoutPreserved = Items.Find(Existing, Mutated) && Mutated == "StructStringInoutMutated";
		return Items.Num() + 40;
	}

	/**
	 * Return a struct-to-string map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 340/341
	 */
	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, FString> HandleStructStringReturn()
	{
		TMap<FDelegateKeyValueMapKey, FString> Items;
		Items.Add(MakeKey(340, n"StructStringReturnA"), "StructStringReturnA");
		Items.Add(MakeKey(341, n"StructStringReturnB"), "StructStringReturnB");
		return Items;
	}

	/**
	 * WorldStory: BeginPlay binds and executes the struct-string map delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return StructStringValueResult 2 and StructStringOutB preserved
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StructStringValueSignal.BindUFunction(this, n"HandleStructStringValue");
		StructStringInSignal.BindUFunction(this, n"HandleStructStringIn");
		StructStringOutSignal.BindUFunction(this, n"HandleStructStringOut");
		StructStringInoutSignal.BindUFunction(this, n"HandleStructStringInout");
		StructStringReturnSignal.BindUFunction(this, n"HandleStructStringReturn");

		TMap<FDelegateKeyValueMapKey, FString> StructStringValueItems;
		StructStringValueItems.Add(MakeKey(300, n"StructStringValueA"), "StructStringValueA");
		StructStringValueItems.Add(MakeKey(301, n"StructStringValueB"), "StructStringValueB");
		StructStringValueResult = StructStringValueSignal.Execute(StructStringValueItems);

		TMap<FDelegateKeyValueMapKey, FString> StructStringInItems;
		StructStringInItems.Add(MakeKey(310, n"StructStringInA"), "StructStringInA");
		StructStringInItems.Add(MakeKey(311, n"StructStringInB"), "StructStringInB");
		StructStringInResult = StructStringInSignal.Execute(StructStringInItems);

		StructStringOutSignal.Execute(StructStringOutResult);
		FString StructStringOutFound;
		StructStringOutPreserved =
			StructStringOutResult.Find(MakeKey(321, n"StructStringOutB"), StructStringOutFound)
			&& StructStringOutFound == "StructStringOutB";

		StructStringInoutResultItems.Add(MakeKey(330, n"StructStringInoutA"), "StructStringInoutA");
		StructStringInoutResult = StructStringInoutSignal.Execute(StructStringInoutResultItems);

		StructStringReturnResult = StructStringReturnSignal.Execute();
		FString StructStringReturnFound;
		StructStringReturnPreserved =
			StructStringReturnResult.Find(MakeKey(341, n"StructStringReturnB"), StructStringReturnFound)
			&& StructStringReturnFound == "StructStringReturnB";
	}

	/**
	 * Observe the default StructStringValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default StructStringValueResult
	 */
	UFUNCTION()
	int StructStringValueResultDefaultZero()
	{
		return StructStringValueResult;
	}

	/**
	 * Observe empty struct-to-string map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyStringMapDefaultNum()
	{
		TMap<FDelegateKeyValueMapKey, FString> Items;
		return Items.Num();
	}

	/**
	 * Observe Find of a zero key on an empty map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map and a default key
	 * @Return true when Find misses and Found stays empty
	 * @Boundary zero-key miss
	 */
	UFUNCTION()
	bool ZeroKeyMissingBoundary()
	{
		TMap<FDelegateKeyValueMapKey, FString> Items;
		FDelegateKeyValueMapKey Zero;
		FString Found;
		if (Items.Find(Zero, Found))
		{
			return false;
		}
		return Found.Len() == 0;
	}
}
