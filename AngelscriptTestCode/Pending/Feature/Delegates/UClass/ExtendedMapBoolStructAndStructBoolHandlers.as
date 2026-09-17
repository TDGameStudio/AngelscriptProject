/**
 * @version v1
 * @summary Bool-struct and struct-bool handlers. HandleBoolStructValue preserves Score 102 / BoolValueFalse. HandleStructBoolValue !Found for false value. Empty map Num 0. False-key lookup.
 * @topic Feature
 */
/**
 * @version root
 * @summary Bool-struct and struct-bool handlers. HandleBoolStructValue preserves Score 102 / BoolValueFalse. HandleStructBoolValue !Found for false value. Empty map Num 0. False-key lookup.
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
	 * @Covers Delegates.ExtendedMapBoolStructAndStructBoolHandlers
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
	 * @Covers Delegates.ExtendedMapBoolStructAndStructBoolHandlers
	 * @Inputs none
	 * @Return uint32(ID * 887) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 887) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FDelegateExtendedMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructExtendedMapDelegateActor : AActor
{
	UPROPERTY()
	bool BoolStructValuePreserved = false;

	UPROPERTY()
	bool BoolStructInPreserved = false;

	UPROPERTY()
	bool BoolStructInoutPreserved = false;

	UPROPERTY()
	int BoolStructInoutResult = 0;

	UPROPERTY()
	TMap<bool, FDelegateExtendedMapValue> BoolStructInoutResultItems;

	UPROPERTY()
	bool StructBoolValuePreserved = false;

	UPROPERTY()
	bool StructBoolInPreserved = false;

	UPROPERTY()
	bool StructBoolInoutPreserved = false;

	UPROPERTY()
	TMap<FDelegateExtendedMapKey, bool> StructBoolInoutResultItems;

	/**
	 * Build an extended map key from an id and tag.
	 *
	 * @Covers Delegates.ExtendedMapBoolStructAndStructBoolHandlers
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
	 * Build an extended map value from a score and label.
	 *
	 * @Covers Delegates.ExtendedMapBoolStructAndStructBoolHandlers
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FDelegateExtendedMapValue MakeValue(int Score, FString Label)
	{
		FDelegateExtendedMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a bool-to-struct map by value and record Find(false) Score 102.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleBoolStructValue(TMap<bool, FDelegateExtendedMapValue> Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructValuePreserved =
			Items.Find(false, Found)
			&& Found.Score == 102
			&& Found.Label == "BoolValueFalse";
		return Items.Num();
	}

	/**
	 * Count a const bool-to-struct map as &in and record Find(true) Score 111.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<bool, FDelegateExtendedMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 10
	 */
	UFUNCTION()
	int HandleBoolStructIn(const TMap<bool, FDelegateExtendedMapValue>&in Items)
	{
		FDelegateExtendedMapValue Found;
		BoolStructInPreserved =
			Items.Find(true, Found)
			&& Found.Score == 111
			&& Found.Label == "BoolInTrue";
		return Items.Num() + 10;
	}

	/**
	 * Fill an &out bool-to-struct map with true/false values.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<bool, FDelegateExtendedMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleBoolStructOut(TMap<bool, FDelegateExtendedMapValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

	/**
	 * Mutate an &inout bool-to-struct map, rewriting true to Score 231.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<bool, FDelegateExtendedMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleBoolStructInout(TMap<bool, FDelegateExtendedMapValue>&inout Items)
	{
		FDelegateExtendedMapValue Found;
		if (Items.Find(true, Found))
		{
			Found.Score += 100;
			Found.Label = "BoolInoutMutated";
			Items.Add(true, Found);
		}
		Items.Add(false, MakeValue(132, "BoolInoutAdded"));
		BoolStructInoutResultItems = Items;
		FDelegateExtendedMapValue Mutated;
		BoolStructInoutPreserved =
			Items.Find(true, Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "BoolInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a bool-to-struct map of true/false values.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return true/false entries
	 */
	UFUNCTION()
	TMap<bool, FDelegateExtendedMapValue> HandleBoolStructReturn()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));
		return Items;
	}

	/**
	 * Count a struct-to-bool map by value and record Find key 201 as false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleStructBoolValue(TMap<FDelegateExtendedMapKey, bool> Items)
	{
		bool Found = true;
		StructBoolValuePreserved =
			Items.Find(MakeKey(201, n"StructBoolValueB"), Found)
			&& !Found;
		return Items.Num();
	}

	/**
	 * Count a const struct-to-bool map as &in and record Find key 211 as true.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<FDelegateExtendedMapKey, bool>&in
	 * @Inputs Items
	 * @Return Items.Num() + 20
	 */
	UFUNCTION()
	int HandleStructBoolIn(const TMap<FDelegateExtendedMapKey, bool>&in Items)
	{
		bool Found = false;
		StructBoolInPreserved =
			Items.Find(MakeKey(211, n"StructBoolInB"), Found)
			&& Found;
		return Items.Num() + 20;
	}

	/**
	 * Fill an &out struct-to-bool map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, bool>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleStructBoolOut(TMap<FDelegateExtendedMapKey, bool>&out Items)
	{
		Items.Add(MakeKey(220, n"StructBoolOutA"), true);
		Items.Add(MakeKey(221, n"StructBoolOutB"), false);
	}

	/**
	 * Mutate an &inout struct-to-bool map, flipping key 230.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<FDelegateExtendedMapKey, bool>&inout
	 * @Inputs Items
	 * @Return Items.Num() + (Mutated ? 40 : 50)
	 */
	UFUNCTION()
	int HandleStructBoolInout(TMap<FDelegateExtendedMapKey, bool>&inout Items)
	{
		FDelegateExtendedMapKey Existing = MakeKey(230, n"StructBoolInoutA");
		bool Found = false;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, !Found);
		}
		Items.Add(MakeKey(231, n"StructBoolInoutB"), true);
		StructBoolInoutResultItems = Items;
		bool Mutated = false;
		StructBoolInoutPreserved =
			Items.Find(Existing, Mutated)
			&& !Mutated;
		return Items.Num() + (Mutated ? 40 : 50);
	}

	/**
	 * Return a struct-to-bool map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 240/241
	 */
	UFUNCTION()
	TMap<FDelegateExtendedMapKey, bool> HandleStructBoolReturn()
	{
		TMap<FDelegateExtendedMapKey, bool> Items;
		Items.Add(MakeKey(240, n"StructBoolReturnA"), true);
		Items.Add(MakeKey(241, n"StructBoolReturnB"), false);
		return Items;
	}

	/**
	 * Observe empty bool-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyBoolMapDefaultNum()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe MakeValue of Score 0 empty Label.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Score 0 empty Label
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int MakeValueZeroBoundary()
	{
		FDelegateExtendedMapValue Value = MakeValue(0, "");
		return Value.Score + Value.Label.Len();
	}

	/**
	 * Observe Find(false) on an empty map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map
	 * @Return true when Find misses and Score stays 0
	 * @Boundary false-key miss
	 */
	UFUNCTION()
	bool FalseKeyMissingBoundary()
	{
		TMap<bool, FDelegateExtendedMapValue> Items;
		FDelegateExtendedMapValue Found;
		if (Items.Find(false, Found))
		{
			return false;
		}
		return Found.Score == 0;
	}
}
/** @end */
