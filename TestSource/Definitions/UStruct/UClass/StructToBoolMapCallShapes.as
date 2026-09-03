/**
 * TMap<FStruct,bool> value/in/out/inout/return call shapes. C++ counts, fills,
 * mutates, and returns those maps. Keep StructBool* UPROPERTY names.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.StructToBoolMapCallShapes
 * @Harness UClass
 * @Tag Definitions.UStruct.StructToBoolMapCallShapes
 * @Provenance Theme: Definitions.UStruct. Positive block 4: TMap<FStruct,bool> value/in/out/inout/return.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13954-14016.
 * @Provenance Isolation=none: complete program wrapping CountStructBool*. Oracle: ValueFalse finds !Found;
 * @Provenance InTrue finds true; inout mutates true to false. Extra: empty count 0. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FMapPrimitiveKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs another FMapPrimitiveKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FMapPrimitiveKey&in Other) const
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
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructMapPrimitiveMatrixActor : AActor
{
	UPROPERTY()
	int StructBoolValueCount = 0;

	UPROPERTY()
	int StructBoolInCount = 0;

	UPROPERTY()
	TMap<FMapPrimitiveKey, bool> StructBoolInout;

	UPROPERTY()
	bool StructBoolValuePreserved = false;

	UPROPERTY()
	bool StructBoolInPreserved = false;

	UPROPERTY()
	bool StructBoolInoutSawOriginal = false;

	UPROPERTY()
	bool StructBoolInoutMutated = false;

	UPROPERTY()
	bool StructBoolReturnPreserved = false;

	/**
	 * Build a primitive map key from an id and tag.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FMapPrimitiveKey MakeKey(int ID, FName Tag)
	{
		FMapPrimitiveKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Count a by-value struct-to-bool map and preserve ValueFalse as false.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs a TMap of FMapPrimitiveKey to bool
	 * @Return Items.Num() stored in StructBoolValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructBoolValue(TMap<FMapPrimitiveKey, bool> Items)
	{
		StructBoolValueCount = Items.Num();
		bool Found = true;
		StructBoolValuePreserved =
			Items.Find(MakeKey(301, n"ValueFalse"), Found)
			&& !Found;
		return StructBoolValueCount;
	}

	/**
	 * Count a const-in struct-to-bool map and preserve InTrue as true.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs a const &in TMap of FMapPrimitiveKey to bool
	 * @Return Items.Num() stored in StructBoolInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructBoolIn(const TMap<FMapPrimitiveKey, bool>&in Items)
	{
		StructBoolInCount = Items.Num();
		bool Found = false;
		StructBoolInPreserved =
			Items.Find(MakeKey(310, n"InTrue"), Found)
			&& Found;
		return StructBoolInCount;
	}

	/**
	 * Fill an out struct-to-bool map with true and false entries.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs an &out TMap of FMapPrimitiveKey to bool
	 * @Return Items with OutTrue and OutFalse
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructBoolOut(TMap<FMapPrimitiveKey, bool>&out Items)
	{
		Items.Add(MakeKey(320, n"OutTrue"), true);
		Items.Add(MakeKey(321, n"OutFalse"), false);
	}

	/**
	 * Mutate an inout struct-to-bool map from true to false.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs an &inout TMap of FMapPrimitiveKey to bool
	 * @Return StructBoolInout copied from Items after mutate
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructBoolInout(TMap<FMapPrimitiveKey, bool>&inout Items)
	{
		FMapPrimitiveKey Existing = MakeKey(330, n"InoutTrue");
		bool Found = false;
		StructBoolInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found;
		Items.Add(Existing, false);
		Items.Add(MakeKey(331, n"InoutAdded"), true);
		StructBoolInout = Items;

		bool Mutated = true;
		StructBoolInoutMutated =
			Items.Find(Existing, Mutated)
			&& !Mutated;
	}

	/**
	 * Return a struct-to-bool map with true and false entries.
	 *
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs none
	 * @Return a TMap with ReturnTrue and ReturnFalse
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FMapPrimitiveKey, bool> ReturnStructBool()
	{
		TMap<FMapPrimitiveKey, bool> Items;
		Items.Add(MakeKey(340, n"ReturnTrue"), true);
		Items.Add(MakeKey(341, n"ReturnFalse"), false);

		bool Found = true;
		StructBoolReturnPreserved =
			Items.Find(MakeKey(341, n"ReturnFalse"), Found)
			&& !Found;
		return Items;
	}

	/**
	 * Observe that an empty struct-to-bool map counts 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs a default TMap of FMapPrimitiveKey to bool
	 * @Return true when count is 0, preserved is false, and inout is empty
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool StructBoolDefaultEmpty()
	{
		TMap<FMapPrimitiveKey, bool> Empty;
		if (CountStructBoolValue(Empty) != 0)
		{
			return false;
		}
		if (StructBoolValuePreserved)
		{
			return false;
		}
		return StructBoolInout.Num() == 0;
	}

	/**
	 * Observe struct-to-bool value/in/out/inout/return oracles.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs populated value/in/inout maps plus Fill/Mutate/Return
	 * @Return true when counts, preserved flags, and ReturnFalse match
	 */
	UFUNCTION()
	bool StructBoolNominalMatrix()
	{
		TMap<FMapPrimitiveKey, bool> ValueItems;
		ValueItems.Add(MakeKey(300, n"ValueTrue"), true);
		ValueItems.Add(MakeKey(301, n"ValueFalse"), false);
		TMap<FMapPrimitiveKey, bool> InItems;
		InItems.Add(MakeKey(310, n"InTrue"), true);
		TMap<FMapPrimitiveKey, bool> OutItems;
		FillStructBoolOut(OutItems);
		TMap<FMapPrimitiveKey, bool> InoutItems;
		InoutItems.Add(MakeKey(330, n"InoutTrue"), true);
		MutateStructBoolInout(InoutItems);
		TMap<FMapPrimitiveKey, bool> Returned = ReturnStructBool();
		bool Found = true;
		if (CountStructBoolValue(ValueItems) != 2)
		{
			return false;
		}
		if (!StructBoolValuePreserved)
		{
			return false;
		}
		if (CountStructBoolIn(InItems) != 1)
		{
			return false;
		}
		if (!StructBoolInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!StructBoolInoutSawOriginal)
		{
			return false;
		}
		if (!StructBoolInoutMutated)
		{
			return false;
		}
		if (!StructBoolReturnPreserved)
		{
			return false;
		}
		if (!Returned.Find(MakeKey(341, n"ReturnFalse"), Found))
		{
			return false;
		}
		return !Found;
	}

	/**
	 * Observe Count of a single false value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToBoolMapCallShapes
	 * @Inputs Add of ValueFalse as false
	 * @Return true when count is 1 and preserved is true
	 * @Boundary false value
	 */
	UFUNCTION()
	bool StructBoolFalseValueBoundary()
	{
		TMap<FMapPrimitiveKey, bool> Items;
		Items.Add(MakeKey(301, n"ValueFalse"), false);
		if (CountStructBoolValue(Items) != 1)
		{
			return false;
		}
		return StructBoolValuePreserved;
	}
}
