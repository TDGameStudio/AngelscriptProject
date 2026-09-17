/**
 * @version v1
 * @summary Struct-string and struct-name handlers. HandleStructStringValue preserves StructStringValueB. HandleStructNameValue preserves StructNameValueB. Empty TMap Num 0. Zero-key miss.
 * @topic Feature
 */
/**
 * @version root
 * @summary Struct-string and struct-name handlers. HandleStructStringValue preserves StructStringValueB. HandleStructNameValue preserves StructNameValueB. Empty TMap Num 0. Zero-key miss.
 * @topic Baseline
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
	 * @Covers Delegates.MapKeyValueStructStringAndStructNameHandlers
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
	 * @Covers Delegates.MapKeyValueStructStringAndStructNameHandlers
	 * @Inputs none
	 * @Return uint32(ID * 929) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringInoutPreserved = false;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FString> StructStringInoutResultItems;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameInoutPreserved = false;

	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameInoutResultItems;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers Delegates.MapKeyValueStructStringAndStructNameHandlers
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
		StructStringValuePreserved =
			Items.Find(MakeKey(301, n"StructStringValueB"), Found)
			&& Found == "StructStringValueB";
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
		StructStringInPreserved =
			Items.Find(MakeKey(311, n"StructStringInB"), Found)
			&& Found == "StructStringInB";
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
		StructStringInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == "StructStringInoutMutated";
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
	 * Count a struct-to-name map by value and record Find StructNameValueB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructNameValue(TMap<FDelegateKeyValueMapKey, FName> Items)
	{
		FName Found;
		StructNameValuePreserved =
			Items.Find(MakeKey(401, n"StructNameValueB"), Found)
			&& Found == n"StructNameValueB";
		return Items.Num();
	}

	/**
	 * Count a const struct-to-name map as &in and record Find StructNameInB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateKeyValueMapKey, FName>&in
	 * @Inputs Items
	 * @Return Items.Num() + 50
	 */
	UFUNCTION()
	int HandleStructNameIn(const TMap<FDelegateKeyValueMapKey, FName>&in Items)
	{
		FName Found;
		StructNameInPreserved =
			Items.Find(MakeKey(411, n"StructNameInB"), Found)
			&& Found == n"StructNameInB";
		return Items.Num() + 50;
	}

	/**
	 * Fill an &out struct-to-name map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, FName>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructNameOut(TMap<FDelegateKeyValueMapKey, FName>&out Items)
	{
		Items.Add(MakeKey(420, n"StructNameOutA"), n"StructNameOutA");
		Items.Add(MakeKey(421, n"StructNameOutB"), n"StructNameOutB");
	}

	/**
	 * Mutate an &inout struct-to-name map, rewriting key 430.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateKeyValueMapKey, FName>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 60
	 */
	UFUNCTION()
	int HandleStructNameInout(TMap<FDelegateKeyValueMapKey, FName>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(430, n"StructNameInoutA");
		FName Found;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, n"StructNameInoutMutated");
		}
		Items.Add(MakeKey(431, n"StructNameInoutB"), n"StructNameInoutAdded");
		StructNameInoutResultItems = Items;
		FName Mutated;
		StructNameInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == n"StructNameInoutMutated";
		return Items.Num() + 60;
	}

	/**
	 * Return a struct-to-name map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 440/441
	 */
	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, FName> HandleStructNameReturn()
	{
		TMap<FDelegateKeyValueMapKey, FName> Items;
		Items.Add(MakeKey(440, n"StructNameReturnA"), n"StructNameReturnA");
		Items.Add(MakeKey(441, n"StructNameReturnB"), n"StructNameReturnB");
		return Items;
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
	 * Observe MakeKey of ID 0 empty Tag.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs ID 0 Tag empty
	 * @Return 0
	 * @Boundary zero key
	 */
	UFUNCTION()
	int MakeKeyZeroBoundary()
	{
		FDelegateKeyValueMapKey Key = MakeKey(0, n"");
		return Key.ID;
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
/** @end */
