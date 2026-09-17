/**
 * @version v1
 * @summary Struct-float map handlers. HandleStructFloatValue preserves 302.5f. Inout mutates 331.5f to 431.5f. Empty TMap Num 0. 0.0f key miss.
 * @topic Feature
 */
/**
 * @version root
 * @summary Struct-float map handlers. HandleStructFloatValue preserves 302.5f. Inout mutates 331.5f to 431.5f. Empty TMap Num 0. 0.0f key miss.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FDelegateExtendedMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers Delegates.ExtendedMapStructFloatHandlers
	 * @Inputs another FDelegateExtendedMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FDelegateExtendedMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 887 plus Tag.GetHash().
	 *
	 * @Covers Delegates.ExtendedMapStructFloatHandlers
	 * @Inputs none
	 * @Return uint32(ID * 887) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	bool StructFloatValuePreserved = false;

	UPROPERTY()
	bool StructFloatInPreserved = false;

	UPROPERTY()
	bool StructFloatInoutPreserved = false;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, float> StructFloatInoutResultItems;

	/**
	 * Build an extended map key from an id and tag.
	 *
	 * @Covers Delegates.ExtendedMapStructFloatHandlers
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FDelegateExtendedMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateExtendedMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Count a struct-to-float map by value and record Find 302.5f.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructFloatValue(TMap<FDelegateExtendedMapKey, float> Items)
	{
		float Found = 0.0f;
		StructFloatValuePreserved =
			Items.Find(MakeKey(301, n"StructFloatValueB"), Found)
			&& Found == 302.5f;
		return Items.Num();
	}

	/**
	 * Count a const struct-to-float map as &in and record Find 312.5f.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateExtendedMapKey, float>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleStructFloatIn(const TMap<FDelegateExtendedMapKey, float>&in Items)
	{
		float Found = 0.0f;
		StructFloatInPreserved =
			Items.Find(MakeKey(311, n"StructFloatInB"), Found)
			&& Found == 312.5f;
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out struct-to-float map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, float>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructFloatOut(TMap<FDelegateExtendedMapKey, float>&out Items)
	{
		Items.Add(MakeKey(320, n"StructFloatOutA"), 321.5f);
		Items.Add(MakeKey(321, n"StructFloatOutB"), 322.5f);
	}

	/**
	 * Mutate an &inout struct-to-float map, adding 100 to key 330.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, float>&inout
	 * @Inputs Items
	 * @Return Items.Num() + int(Mutated)
	 */
	UFUNCTION()
	int HandleStructFloatInout(TMap<FDelegateExtendedMapKey, float>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(330, n"StructFloatInoutA");
		float Found = 0.0f;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, Found + 100.0f);
		}
		Items.Add(MakeKey(331, n"StructFloatInoutB"), 332.5f);
		StructFloatInoutResultItems = Items;
		float Mutated = 0.0f;
		StructFloatInoutPreserved =
			Items.Find(Existing, Mutated)
			&& Mutated == 431.5f;
		return Items.Num() + int(Mutated);
	}

	/**
	 * Return a struct-to-float map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 340/341
	 */
	UFUNCTION()
	TMap<FDelegateExtendedMapKey, float> HandleStructFloatReturn()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
		Items.Add(MakeKey(340, n"StructFloatReturnA"), 341.5f);
		Items.Add(MakeKey(341, n"StructFloatReturnB"), 342.5f);
		return Items;
	}

	/**
	 * Observe empty struct-to-float map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyFloatMapDefaultNum()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
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
		FDelegateExtendedMapKey Key = MakeKey(0, n"");
		return Key.ID;
	}

	/**
	 * Observe Find of a zero key on an empty map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map and a default key
	 * @Return true when Find misses and Found stays 0
	 * @Boundary 0.0f key miss
	 */
	UFUNCTION()
	bool ZeroKeyMissingBoundary()
	{
		TMap<FDelegateExtendedMapKey, float> Items;
		FDelegateExtendedMapKey Zero;
		float Found = 0.0f;
		if (Items.Find(Zero, Found))
		{
			return false;
		}
		return Found == 0.0f;
	}
}
/** @end */
