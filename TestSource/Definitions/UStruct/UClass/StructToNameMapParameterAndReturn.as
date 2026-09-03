/**
 * TMap of FStruct to FName as value/in/out/inout/return. C++ checks ValueB
 * n"StructNameValueB" and inout mutation to n"StructNameInoutMutated".
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.StructToNameMapParameterAndReturn
 * @Harness UClass
 * @Tag Definitions.UStruct.StructToNameMapParameterAndReturn
 * @Provenance Theme: Definitions.UStruct. Positive block 4: TMap<FStruct,FName> value/in/out/inout/return.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12530-12592.
 * @Provenance Isolation=none: complete program wrapping CountStructName*. Oracle: ValueB n"StructNameValueB",
 * @Provenance inout mutates n"StructNameInoutMutated". Extra: empty count 0. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FMapParamKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two keys by ID and Tag.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs another FMapParamKey
	 * @Return true when ID and Tag match
	 * @Param Other the other key
	 */
	bool opEquals(const FMapParamKey&in Other) const
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
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int StructNameValueCount = 0;

	UPROPERTY()
	int StructNameInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FName> StructNameInout;

	UPROPERTY()
	bool StructNameValuePreserved = false;

	UPROPERTY()
	bool StructNameInPreserved = false;

	UPROPERTY()
	bool StructNameInoutSawOriginal = false;

	UPROPERTY()
	bool StructNameInoutMutated = false;

	UPROPERTY()
	bool StructNameReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs ID and Tag
	 * @Return a key holding those fields
	 * @Param ID the key id
	 * @Param Tag the key tag
	 */
	FMapParamKey MakeKey(int ID, FName Tag)
	{
		FMapParamKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	/**
	 * Count a by-value struct-to-name map and record ValueB.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs a TMap of FMapParamKey to FName
	 * @Return Items.Num() stored in StructNameValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructNameValue(TMap<FMapParamKey, FName> Items)
	{
		StructNameValueCount = Items.Num();
		FName Found;
		StructNameValuePreserved =
			Items.Find(MakeKey(401, n"ValueB"), Found)
			&& Found == n"StructNameValueB";
		return StructNameValueCount;
	}

	/**
	 * Count a const-in struct-to-name map and record InB.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs a const &in TMap of FMapParamKey to FName
	 * @Return Items.Num() stored in StructNameInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructNameIn(const TMap<FMapParamKey, FName>&in Items)
	{
		StructNameInCount = Items.Num();
		FName Found;
		StructNameInPreserved =
			Items.Find(MakeKey(411, n"InB"), Found)
			&& Found == n"StructNameInB";
		return StructNameInCount;
	}

	/**
	 * Fill an out struct-to-name map with OutA/OutB.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs an &out TMap of FMapParamKey to FName
	 * @Return Items with OutA and OutB
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructNameOut(TMap<FMapParamKey, FName>&out Items)
	{
		Items.Add(MakeKey(420, n"OutA"), n"StructNameOutA");
		Items.Add(MakeKey(421, n"OutB"), n"StructNameOutB");
	}

	/**
	 * Mutate an inout struct-to-name map, overwriting InoutA.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs an &inout TMap of FMapParamKey to FName
	 * @Return StructNameInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructNameInout(TMap<FMapParamKey, FName>&inout Items)
	{
		FMapParamKey Existing = MakeKey(430, n"InoutA");
		FName Found;
		StructNameInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == n"StructNameInoutA";
		Items.Add(Existing, n"StructNameInoutMutated");
		Items.Add(MakeKey(431, n"InoutB"), n"StructNameInoutAdded");
		StructNameInout = Items;

		FName Mutated;
		StructNameInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == n"StructNameInoutMutated";
	}

	/**
	 * Return a struct-to-name map preserving ReturnB.
	 *
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnA and ReturnB
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, FName> ReturnStructName()
	{
		TMap<FMapParamKey, FName> Items;
		Items.Add(MakeKey(440, n"ReturnA"), n"StructNameReturnA");
		Items.Add(MakeKey(441, n"ReturnB"), n"StructNameReturnB");

		FName Found;
		StructNameReturnPreserved =
			Items.Find(MakeKey(441, n"ReturnB"), Found)
			&& Found == n"StructNameReturnB";
		return Items;
	}

	/**
	 * Observe an empty struct-to-name map count.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs CountStructNameValue of an empty map
	 * @Return true when the count is 0 and flags stay false
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool StructNameDefaultEmpty()
	{
		TMap<FMapParamKey, FName> Empty;
		if (CountStructNameValue(Empty) != 0)
		{
			return false;
		}
		if (StructNameValuePreserved)
		{
			return false;
		}
		return StructNameInout.Num() == 0;
	}

	/**
	 * Observe value/in/out/inout/return of TMap<FStruct,FName>.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs populated value/in/inout maps plus Fill and Return
	 * @Return true when counts are 2, names preserve, and inout mutates
	 */
	UFUNCTION()
	bool StructNameNominalMatrix()
	{
		TMap<FMapParamKey, FName> ValueItems;
		ValueItems.Add(MakeKey(400, n"ValueA"), n"StructNameValueA");
		ValueItems.Add(MakeKey(401, n"ValueB"), n"StructNameValueB");
		TMap<FMapParamKey, FName> InItems;
		InItems.Add(MakeKey(410, n"InA"), n"StructNameInA");
		InItems.Add(MakeKey(411, n"InB"), n"StructNameInB");
		TMap<FMapParamKey, FName> OutItems;
		FillStructNameOut(OutItems);
		TMap<FMapParamKey, FName> InoutItems;
		InoutItems.Add(MakeKey(430, n"InoutA"), n"StructNameInoutA");
		MutateStructNameInout(InoutItems);
		TMap<FMapParamKey, FName> Returned = ReturnStructName();
		FName Found;
		if (CountStructNameValue(ValueItems) != 2)
		{
			return false;
		}
		if (!StructNameValuePreserved)
		{
			return false;
		}
		if (CountStructNameIn(InItems) != 2)
		{
			return false;
		}
		if (!StructNameInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!StructNameInoutSawOriginal)
		{
			return false;
		}
		if (!StructNameInoutMutated)
		{
			return false;
		}
		if (!StructNameReturnPreserved)
		{
			return false;
		}
		if (!Returned.Find(MakeKey(441, n"ReturnB"), Found))
		{
			return false;
		}
		return Found == n"StructNameReturnB";
	}

	/**
	 * Observe Find of a none-name empty key.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToNameMapParameterAndReturn
	 * @Inputs Add of MakeKey(0, n"") mapped to n""
	 * @Return true when Find yields n""
	 * @Boundary none name
	 */
	UFUNCTION()
	bool StructNameNoneNameBoundary()
	{
		TMap<FMapParamKey, FName> Items;
		Items.Add(MakeKey(0, n""), n"");
		FName Found = n"Sentinel";
		if (!Items.Find(MakeKey(0, n""), Found))
		{
			return false;
		}
		return Found == n"";
	}
}
