/**
 * @version v1
 * @summary TMap of FStruct to float as value/in/out/inout/return. C++ checks ValueFloatB 502.5f and inout mutation to 631.5f.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of FStruct to float as value/in/out/inout/return. C++ checks ValueFloatB 502.5f and inout mutation to 631.5f.
 * @topic Baseline
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
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
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
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
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
	int StructFloatValueCount = 0;

	UPROPERTY()
	int StructFloatInCount = 0;

	UPROPERTY()
	TMap<FMapPrimitiveKey, float> StructFloatInout;

	UPROPERTY()
	bool StructFloatValuePreserved = false;

	UPROPERTY()
	bool StructFloatInPreserved = false;

	UPROPERTY()
	bool StructFloatInoutSawOriginal = false;

	UPROPERTY()
	bool StructFloatInoutMutated = false;

	UPROPERTY()
	bool StructFloatReturnPreserved = false;

	/**
	 * Build a primitive map key from an id and tag.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
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
	 * Count a by-value struct-to-float map and record ValueFloatB 502.5f.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs a TMap of FMapPrimitiveKey to float
	 * @Return Items.Num() stored in StructFloatValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructFloatValue(TMap<FMapPrimitiveKey, float> Items)
	{
		StructFloatValueCount = Items.Num();
		float Found = 0.0f;
		StructFloatValuePreserved =
			Items.Find(MakeKey(501, n"ValueFloatB"), Found)
			&& Found == 502.5f;
		return StructFloatValueCount;
	}

	/**
	 * Count a const-in struct-to-float map and record InFloatB 512.5f.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs a const &in TMap of FMapPrimitiveKey to float
	 * @Return Items.Num() stored in StructFloatInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructFloatIn(const TMap<FMapPrimitiveKey, float>&in Items)
	{
		StructFloatInCount = Items.Num();
		float Found = 0.0f;
		StructFloatInPreserved =
			Items.Find(MakeKey(511, n"InFloatB"), Found)
			&& Found == 512.5f;
		return StructFloatInCount;
	}

	/**
	 * Fill an out struct-to-float map with OutFloatA/OutFloatB.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs an &out TMap of FMapPrimitiveKey to float
	 * @Return Items with 521.5f and 522.5f
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructFloatOut(TMap<FMapPrimitiveKey, float>&out Items)
	{
		Items.Add(MakeKey(520, n"OutFloatA"), 521.5f);
		Items.Add(MakeKey(521, n"OutFloatB"), 522.5f);
	}

	/**
	 * Mutate an inout struct-to-float map, overwriting InoutFloatA to 631.5f.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs an &inout TMap of FMapPrimitiveKey to float
	 * @Return StructFloatInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructFloatInout(TMap<FMapPrimitiveKey, float>&inout Items)
	{
		FMapPrimitiveKey Existing = MakeKey(530, n"InoutFloatA");
		float Found = 0.0f;
		StructFloatInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == 531.5f;
		Items.Add(Existing, 631.5f);
		Items.Add(MakeKey(531, n"InoutFloatB"), 632.5f);
		StructFloatInout = Items;

		float Mutated = 0.0f;
		StructFloatInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == 631.5f;
	}

	/**
	 * Return a struct-to-float map preserving ReturnFloatB 542.5f.
	 *
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnFloatA 541.5f and ReturnFloatB 542.5f
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FMapPrimitiveKey, float> ReturnStructFloat()
	{
		TMap<FMapPrimitiveKey, float> Items;
		Items.Add(MakeKey(540, n"ReturnFloatA"), 541.5f);
		Items.Add(MakeKey(541, n"ReturnFloatB"), 542.5f);

		float Found = 0.0f;
		StructFloatReturnPreserved =
			Items.Find(MakeKey(541, n"ReturnFloatB"), Found)
			&& Found == 542.5f;
		return Items;
	}

	/**
	 * Observe an empty struct-to-float map count.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs CountStructFloatValue of an empty map
	 * @Return true when the count is 0 and flags stay false
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool StructFloatDefaultEmpty()
	{
		TMap<FMapPrimitiveKey, float> Empty;
		if (CountStructFloatValue(Empty) != 0)
		{
			return false;
		}
		if (StructFloatValuePreserved)
		{
			return false;
		}
		return StructFloatInout.Num() == 0;
	}

	/**
	 * Observe value/in/out/inout/return of TMap<FStruct,float>.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs populated value/in/inout maps plus Fill and Return
	 * @Return true when 502.5f preserves and inout mutates to 631.5f
	 */
	UFUNCTION()
	bool StructFloatNominalMatrix()
	{
		TMap<FMapPrimitiveKey, float> ValueItems;
		ValueItems.Add(MakeKey(500, n"ValueFloatA"), 501.5f);
		ValueItems.Add(MakeKey(501, n"ValueFloatB"), 502.5f);
		TMap<FMapPrimitiveKey, float> InItems;
		InItems.Add(MakeKey(510, n"InFloatA"), 511.5f);
		InItems.Add(MakeKey(511, n"InFloatB"), 512.5f);
		TMap<FMapPrimitiveKey, float> OutItems;
		FillStructFloatOut(OutItems);
		TMap<FMapPrimitiveKey, float> InoutItems;
		InoutItems.Add(MakeKey(530, n"InoutFloatA"), 531.5f);
		MutateStructFloatInout(InoutItems);
		TMap<FMapPrimitiveKey, float> Returned = ReturnStructFloat();
		float Found = 0.0f;
		if (CountStructFloatValue(ValueItems) != 2)
		{
			return false;
		}
		if (!StructFloatValuePreserved)
		{
			return false;
		}
		if (CountStructFloatIn(InItems) != 2)
		{
			return false;
		}
		if (!StructFloatInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!StructFloatInoutSawOriginal)
		{
			return false;
		}
		if (!StructFloatInoutMutated)
		{
			return false;
		}
		if (!StructFloatReturnPreserved)
		{
			return false;
		}
		if (!Returned.Find(MakeKey(541, n"ReturnFloatB"), Found))
		{
			return false;
		}
		return Found == 542.5f;
	}

	/**
	 * Observe Find of a zero-key mapped to 0.0f.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToFloatMapParameterAndReturn
	 * @Inputs Add of MakeKey(0, n"") mapped to 0.0f
	 * @Return true when Find yields 0.0f, count is 1, and ValuePreserved is false
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool StructFloatZeroValueBoundary()
	{
		TMap<FMapPrimitiveKey, float> Items;
		Items.Add(MakeKey(0, n""), 0.0f);
		float Found = 1.0f;
		if (!Items.Find(MakeKey(0, n""), Found))
		{
			return false;
		}
		if (Found != 0.0f)
		{
			return false;
		}
		if (CountStructFloatValue(Items) != 1)
		{
			return false;
		}
		return !StructFloatValuePreserved;
	}
}
/** @end */
