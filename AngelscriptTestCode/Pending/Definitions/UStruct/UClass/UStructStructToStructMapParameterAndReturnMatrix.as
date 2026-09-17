/**
 * @version v1
 * @summary TMap of FStruct to FStruct as value/in/out/inout/return. C++ preserves Score 111 Label ValueB, inout mutates 430/InoutMutated, and return 441/ReturnB.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of FStruct to FStruct as value/in/out/inout/return. C++ preserves Score 111 Label ValueB, inout mutates 430/InoutMutated, and return 441/ReturnB.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FStructToStructMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs another FStructToStructMapKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FStructToStructMapKey&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 941 plus Tag.GetHash().
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs none
	 * @Return uint32(ID * 941) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 941) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FStructToStructMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructToStructMapMatrixActor : AActor
{
	UPROPERTY()
	int StructStructMapValueCount = 0;

	UPROPERTY()
	int StructStructMapInCount = 0;

	UPROPERTY()
	TMap<FStructToStructMapKey, FStructToStructMapValue> StructStructMapInout;

	UPROPERTY()
	bool StructStructMapValuePreserved = false;

	UPROPERTY()
	bool StructStructMapInPreserved = false;

	UPROPERTY()
	bool StructStructMapInoutSawOriginal = false;

	UPROPERTY()
	bool StructStructMapInoutMutated = false;

	UPROPERTY()
	bool StructStructMapReturnPreserved = false;

	/**
	 * Build a struct-to-struct map key.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FStructToStructMapKey MakeKey(int ID, FName Tag)
	{
		FStructToStructMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Build a struct-to-struct map value.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FStructToStructMapValue MakeValue(int Score, FString Label)
	{
		FStructToStructMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a by-value struct-to-struct map and record Score 111 on MapValueB.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs a TMap of FStructToStructMapKey to FStructToStructMapValue
	 * @Return Items.Num() stored in StructStructMapValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStructMapValue(TMap<FStructToStructMapKey, FStructToStructMapValue> Items)
	{
		StructStructMapValueCount = Items.Num();
		FStructToStructMapValue Found;
		StructStructMapValuePreserved =
			Items.Find(MakeKey(11, n"MapValueB"), Found)
			&& Found.Score == 111
			&& Found.Label == "ValueB";
		return StructStructMapValueCount;
	}

	/**
	 * Count a const-in struct-to-struct map and record Score 113 on MapInB.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs a const &in TMap of FStructToStructMapKey to FStructToStructMapValue
	 * @Return Items.Num() stored in StructStructMapInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStructMapIn(const TMap<FStructToStructMapKey, FStructToStructMapValue>&in Items)
	{
		StructStructMapInCount = Items.Num();
		FStructToStructMapValue Found;
		StructStructMapInPreserved =
			Items.Find(MakeKey(13, n"MapInB"), Found)
			&& Found.Score == 113
			&& Found.Label == "InB";
		return StructStructMapInCount;
	}

	/**
	 * Fill an out struct-to-struct map with MapOutA/MapOutB.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs an &out TMap of FStructToStructMapKey to FStructToStructMapValue
	 * @Return Items with OutA 220 and OutB 221
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructStructMapOut(TMap<FStructToStructMapKey, FStructToStructMapValue>&out Items)
	{
		Items.Add(MakeKey(20, n"MapOutA"), MakeValue(220, "OutA"));
		Items.Add(MakeKey(21, n"MapOutB"), MakeValue(221, "OutB"));
	}

	/**
	 * Mutate an inout struct-to-struct map, replacing InoutA with 430/InoutMutated.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs an &inout TMap of FStructToStructMapKey to FStructToStructMapValue
	 * @Return StructStructMapInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructStructMapInout(TMap<FStructToStructMapKey, FStructToStructMapValue>&inout Items)
	{
		FStructToStructMapKey Existing = MakeKey(30, n"MapInoutA");
		FStructToStructMapValue Found;
		StructStructMapInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found.Score == 330
			&& Found.Label == "InoutA";

		Items.Remove(Existing);
		Items.Add(Existing, MakeValue(430, "InoutMutated"));
		Items.Add(MakeKey(31, n"MapInoutB"), MakeValue(431, "InoutAdded"));
		StructStructMapInout = Items;

		FStructToStructMapValue Mutated;
		StructStructMapInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated.Score == 430
			&& Mutated.Label == "InoutMutated";
	}

	/**
	 * Return a struct-to-struct map preserving ReturnB Score 441.
	 *
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs none
	 * @Return a TMap with ReturnA 440 and ReturnB 441
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FStructToStructMapKey, FStructToStructMapValue> ReturnStructStructMap()
	{
		TMap<FStructToStructMapKey, FStructToStructMapValue> Items;
		Items.Add(MakeKey(40, n"MapReturnA"), MakeValue(440, "ReturnA"));
		Items.Add(MakeKey(41, n"MapReturnB"), MakeValue(441, "ReturnB"));

		FStructToStructMapValue Found;
		StructStructMapReturnPreserved =
			Items.Find(MakeKey(41, n"MapReturnB"), Found)
			&& Found.Score == 441
			&& Found.Label == "ReturnB";
		return Items;
	}

	/**
	 * Observe an empty struct-to-struct map count.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs CountStructStructMapValue of an empty map
	 * @Return true when the count is 0 and flags stay false
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool StructStructMapDefaultEmpty()
	{
		TMap<FStructToStructMapKey, FStructToStructMapValue> Empty;
		if (CountStructStructMapValue(Empty) != 0)
		{
			return false;
		}
		if (StructStructMapValuePreserved)
		{
			return false;
		}
		return StructStructMapInout.Num() == 0;
	}

	/**
	 * Observe value/in/out/inout/return of TMap<FStruct,FStruct>.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs populated value/in/inout maps plus Fill and Return
	 * @Return true when counts are 2, Score 111 preserves, and inout mutates 430
	 */
	UFUNCTION()
	bool StructStructMapNominalMatrix()
	{
		TMap<FStructToStructMapKey, FStructToStructMapValue> ValueItems;
		ValueItems.Add(MakeKey(10, n"MapValueA"), MakeValue(110, "ValueA"));
		ValueItems.Add(MakeKey(11, n"MapValueB"), MakeValue(111, "ValueB"));
		TMap<FStructToStructMapKey, FStructToStructMapValue> InItems;
		InItems.Add(MakeKey(12, n"MapInA"), MakeValue(112, "InA"));
		InItems.Add(MakeKey(13, n"MapInB"), MakeValue(113, "InB"));
		TMap<FStructToStructMapKey, FStructToStructMapValue> OutItems;
		FillStructStructMapOut(OutItems);
		TMap<FStructToStructMapKey, FStructToStructMapValue> InoutItems;
		InoutItems.Add(MakeKey(30, n"MapInoutA"), MakeValue(330, "InoutA"));
		MutateStructStructMapInout(InoutItems);
		TMap<FStructToStructMapKey, FStructToStructMapValue> Returned = ReturnStructStructMap();
		if (CountStructStructMapValue(ValueItems) != 2)
		{
			return false;
		}
		if (!StructStructMapValuePreserved)
		{
			return false;
		}
		if (CountStructStructMapIn(InItems) != 2)
		{
			return false;
		}
		if (!StructStructMapInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!StructStructMapInoutSawOriginal)
		{
			return false;
		}
		if (!StructStructMapInoutMutated)
		{
			return false;
		}
		if (!StructStructMapReturnPreserved)
		{
			return false;
		}
		return Returned.Num() == 2;
	}

	/**
	 * Observe Find of a zero key mapped to an empty value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructStructToStructMapParameterAndReturnMatrix
	 * @Inputs Add of MakeKey(0, n"") mapped to Score 0
	 * @Return true when Find yields Score 0 and an empty Label
	 * @Boundary zero key
	 */
	UFUNCTION()
	bool StructStructMapZeroKeyBoundary()
	{
		FStructToStructMapKey Zero = MakeKey(0, n"");
		FStructToStructMapValue Empty = MakeValue(0, "");
		TMap<FStructToStructMapKey, FStructToStructMapValue> Items;
		Items.Add(Zero, Empty);
		FStructToStructMapValue Found;
		if (!Items.Find(MakeKey(0, n""), Found))
		{
			return false;
		}
		if (Found.Score != 0)
		{
			return false;
		}
		return Found.Label.Len() == 0;
	}
}
/** @end */
