/**
 * @version v1
 * @summary TMap of FString to FStruct and TMap of FStruct to FString as value/in/out/inout/return. C++ checks StringStruct value 202 and StructString value StructStringValueB.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of FString to FStruct and TMap of FStruct to FString as value/in/out/inout/return. C++ checks StringStruct value 202 and StructString value StructStringValueB.
 * @topic Baseline
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
	 * @Covers UStruct.StringStructMapParameterAndReturn
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
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapParamValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapParamMatrixActor : AActor
{
	UPROPERTY()
	int StringStructValueCount = 0;

	UPROPERTY()
	int StringStructInCount = 0;

	UPROPERTY()
	TMap<FString, FMapParamValue> StringStructInout;

	UPROPERTY()
	bool StringStructValuePreserved = false;

	UPROPERTY()
	bool StringStructInPreserved = false;

	UPROPERTY()
	bool StringStructInoutSawOriginal = false;

	UPROPERTY()
	bool StringStructInoutMutated = false;

	UPROPERTY()
	bool StringStructReturnPreserved = false;

	UPROPERTY()
	int StructStringValueCount = 0;

	UPROPERTY()
	int StructStringInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, FString> StructStringInout;

	UPROPERTY()
	bool StructStringValuePreserved = false;

	UPROPERTY()
	bool StructStringInPreserved = false;

	UPROPERTY()
	bool StructStringInoutSawOriginal = false;

	UPROPERTY()
	bool StructStringInoutMutated = false;

	UPROPERTY()
	bool StructStringReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
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
	 * Build a map value from a score and label.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FMapParamValue MakeValue(int Score, FString Label)
	{
		FMapParamValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Count a by-value FString-to-struct map and record Score 202 on ValueB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs a TMap of FString to FMapParamValue
	 * @Return Items.Num() stored in StringStructValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStringStructValue(TMap<FString, FMapParamValue> Items)
	{
		StringStructValueCount = Items.Num();
		FMapParamValue Found;
		StringStructValuePreserved =
			Items.Find("ValueB", Found)
			&& Found.Score == 202
			&& Found.Label == "StringValueB";
		return StringStructValueCount;
	}

	/**
	 * Count a const-in FString-to-struct map and record Score 212 on InB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs a const &in TMap of FString to FMapParamValue
	 * @Return Items.Num() stored in StringStructInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStringStructIn(const TMap<FString, FMapParamValue>&in Items)
	{
		StringStructInCount = Items.Num();
		FMapParamValue Found;
		StringStructInPreserved =
			Items.Find("InB", Found)
			&& Found.Score == 212
			&& Found.Label == "StringInB";
		return StringStructInCount;
	}

	/**
	 * Fill an out FString-to-struct map with OutA/OutB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs an &out TMap of FString to FMapParamValue
	 * @Return Items with OutA 221 and OutB 222
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStringStructOut(TMap<FString, FMapParamValue>&out Items)
	{
		Items.Add("OutA", MakeValue(221, "StringOutA"));
		Items.Add("OutB", MakeValue(222, "StringOutB"));
	}

	/**
	 * Mutate an inout FString-to-struct map, overwriting InoutA to 331.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs an &inout TMap of FString to FMapParamValue
	 * @Return StringStructInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStringStructInout(TMap<FString, FMapParamValue>&inout Items)
	{
		FMapParamValue Found;
		StringStructInoutSawOriginal =
			Items.Find("InoutA", Found)
			&& Found.Score == 231
			&& Found.Label == "StringInoutA";
		Items.Add("InoutA", MakeValue(331, "StringInoutMutated"));
		Items.Add("InoutB", MakeValue(332, "StringInoutAdded"));
		StringStructInout = Items;

		FMapParamValue Mutated;
		StringStructInoutMutated =
			Items.Find("InoutA", Mutated)
			&& Mutated.Score == 331
			&& Mutated.Label == "StringInoutMutated";
	}

	/**
	 * Return an FString-to-struct map preserving ReturnB Score 242.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnA 241 and ReturnB 242
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FString, FMapParamValue> ReturnStringStruct()
	{
		TMap<FString, FMapParamValue> Items;
		Items.Add("ReturnA", MakeValue(241, "StringReturnA"));
		Items.Add("ReturnB", MakeValue(242, "StringReturnB"));

		FMapParamValue Found;
		StringStructReturnPreserved =
			Items.Find("ReturnB", Found)
			&& Found.Score == 242
			&& Found.Label == "StringReturnB";
		return Items;
	}

	/**
	 * Count a by-value struct-to-string map and record ValueB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs a TMap of FMapParamKey to FString
	 * @Return Items.Num() stored in StructStringValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStringValue(TMap<FMapParamKey, FString> Items)
	{
		StructStringValueCount = Items.Num();
		FString Found;
		StructStringValuePreserved =
			Items.Find(MakeKey(301, n"ValueB"), Found)
			&& Found == "StructStringValueB";
		return StructStringValueCount;
	}

	/**
	 * Count a const-in struct-to-string map and record InB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs a const &in TMap of FMapParamKey to FString
	 * @Return Items.Num() stored in StructStringInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructStringIn(const TMap<FMapParamKey, FString>&in Items)
	{
		StructStringInCount = Items.Num();
		FString Found;
		StructStringInPreserved =
			Items.Find(MakeKey(311, n"InB"), Found)
			&& Found == "StructStringInB";
		return StructStringInCount;
	}

	/**
	 * Fill an out struct-to-string map with OutA/OutB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs an &out TMap of FMapParamKey to FString
	 * @Return Items with OutA and OutB
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructStringOut(TMap<FMapParamKey, FString>&out Items)
	{
		Items.Add(MakeKey(320, n"OutA"), "StructStringOutA");
		Items.Add(MakeKey(321, n"OutB"), "StructStringOutB");
	}

	/**
	 * Mutate an inout struct-to-string map, overwriting InoutA.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs an &inout TMap of FMapParamKey to FString
	 * @Return StructStringInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructStringInout(TMap<FMapParamKey, FString>&inout Items)
	{
		FMapParamKey Existing = MakeKey(330, n"InoutA");
		FString Found;
		StructStringInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found == "StructStringInoutA";
		Items.Add(Existing, "StructStringInoutMutated");
		Items.Add(MakeKey(331, n"InoutB"), "StructStringInoutAdded");
		StructStringInout = Items;

		FString Mutated;
		StructStringInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated == "StructStringInoutMutated";
	}

	/**
	 * Return a struct-to-string map preserving ReturnB.
	 *
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnA and ReturnB
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, FString> ReturnStructString()
	{
		TMap<FMapParamKey, FString> Items;
		Items.Add(MakeKey(340, n"ReturnA"), "StructStringReturnA");
		Items.Add(MakeKey(341, n"ReturnB"), "StructStringReturnB");

		FString Found;
		StructStringReturnPreserved =
			Items.Find(MakeKey(341, n"ReturnB"), Found)
			&& Found == "StructStringReturnB";
		return Items;
	}

	/**
	 * Observe empty string/struct map counts.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs Count of two empty maps
	 * @Return true when both counts are 0 and flags stay false
	 * @Boundary empty maps
	 */
	UFUNCTION()
	bool StringStructDefaultEmpty()
	{
		TMap<FString, FMapParamValue> EmptyString;
		TMap<FMapParamKey, FString> EmptyStruct;
		if (CountStringStructValue(EmptyString) != 0)
		{
			return false;
		}
		if (CountStructStringValue(EmptyStruct) != 0)
		{
			return false;
		}
		if (StringStructValuePreserved)
		{
			return false;
		}
		return !StructStringValuePreserved;
	}

	/**
	 * Observe value/in/out/inout/return of both string/struct map directions.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs populated maps plus Fill and Return on both directions
	 * @Return true when both directions count 2 and preserve/mutate
	 */
	UFUNCTION()
	bool StringStructNominalMatrix()
	{
		TMap<FString, FMapParamValue> StringValue;
		StringValue.Add("ValueA", MakeValue(201, "StringValueA"));
		StringValue.Add("ValueB", MakeValue(202, "StringValueB"));
		TMap<FString, FMapParamValue> StringIn;
		StringIn.Add("InA", MakeValue(211, "StringInA"));
		StringIn.Add("InB", MakeValue(212, "StringInB"));
		TMap<FString, FMapParamValue> StringOut;
		FillStringStructOut(StringOut);
		TMap<FString, FMapParamValue> StringInout;
		StringInout.Add("InoutA", MakeValue(231, "StringInoutA"));
		MutateStringStructInout(StringInout);
		TMap<FString, FMapParamValue> StringReturned = ReturnStringStruct();

		TMap<FMapParamKey, FString> StructValue;
		StructValue.Add(MakeKey(300, n"ValueA"), "StructStringValueA");
		StructValue.Add(MakeKey(301, n"ValueB"), "StructStringValueB");
		TMap<FMapParamKey, FString> StructIn;
		StructIn.Add(MakeKey(310, n"InA"), "StructStringInA");
		StructIn.Add(MakeKey(311, n"InB"), "StructStringInB");
		TMap<FMapParamKey, FString> StructOut;
		FillStructStringOut(StructOut);
		TMap<FMapParamKey, FString> StructInout;
		StructInout.Add(MakeKey(330, n"InoutA"), "StructStringInoutA");
		MutateStructStringInout(StructInout);
		TMap<FMapParamKey, FString> StructReturned = ReturnStructString();
		if (CountStringStructValue(StringValue) != 2)
		{
			return false;
		}
		if (!StringStructValuePreserved)
		{
			return false;
		}
		if (CountStringStructIn(StringIn) != 2)
		{
			return false;
		}
		if (!StringStructInPreserved)
		{
			return false;
		}
		if (StringOut.Num() != 2)
		{
			return false;
		}
		if (!StringStructInoutMutated)
		{
			return false;
		}
		if (!StringStructReturnPreserved)
		{
			return false;
		}
		if (StringReturned.Num() != 2)
		{
			return false;
		}
		if (CountStructStringValue(StructValue) != 2)
		{
			return false;
		}
		if (!StructStringValuePreserved)
		{
			return false;
		}
		if (CountStructStringIn(StructIn) != 2)
		{
			return false;
		}
		if (!StructStringInPreserved)
		{
			return false;
		}
		if (StructOut.Num() != 2)
		{
			return false;
		}
		if (!StructStringInoutMutated)
		{
			return false;
		}
		if (!StructStringReturnPreserved)
		{
			return false;
		}
		return StructReturned.Num() == 2;
	}

	/**
	 * Observe FillStringStructOut of an empty map.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StringStructMapParameterAndReturn
	 * @Inputs FillStringStructOut of an empty map
	 * @Return 2
	 * @Boundary empty out fill
	 */
	UFUNCTION()
	int StringStructEmptyOutBoundary()
	{
		TMap<FString, FMapParamValue> OutItems;
		FillStringStructOut(OutItems);
		return OutItems.Num();
	}
}
/** @end */
