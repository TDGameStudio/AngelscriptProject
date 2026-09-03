/**
 * TMap of FName to FStruct as value/in/out/inout/return. C++ counts two
 * entries and checks Score 102 preserved, inout mutated to 231, and return 142.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.NameToStructMapParameterAndReturn
 * @Harness UClass
 * @Tag Definitions.UStruct.NameToStructMapParameterAndReturn
 * @Provenance Theme: Definitions.UStruct. Positive block 2: TMap<FName,FStruct> value/in/out/inout/return.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueParameterAndReturnMatrix lines 12312-12401.
 * @Provenance Isolation=none: complete program wrapping the raw helpers. Oracle: CountNameStructValue 2
 * @Provenance preserves Score 102; inout mutates 231; return preserves 142. Extra: empty map count 0.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UCoverageStructMapParamValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

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
	 * @Covers UStruct.NameToStructMapParameterAndReturn
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
	 * @Covers UStruct.NameToStructMapParameterAndReturn
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
	int NameStructValueCount = 0;

	UPROPERTY()
	int NameStructInCount = 0;

	UPROPERTY()
	TMap<FName, FMapParamValue> NameStructInout;

	UPROPERTY()
	bool NameStructValuePreserved = false;

	UPROPERTY()
	bool NameStructInPreserved = false;

	UPROPERTY()
	bool NameStructInoutSawOriginal = false;

	UPROPERTY()
	bool NameStructInoutMutated = false;

	UPROPERTY()
	bool NameStructReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
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
	 * @Covers UStruct.NameToStructMapParameterAndReturn
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
	 * Build a map-value object with the given Value.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs Value
	 * @Return a NewObject whose Value was set
	 * @Param Value the object value
	 */
	UCoverageStructMapParamValueObject MakeObject(int Value)
	{
		UCoverageStructMapParamValueObject Object = Cast<UCoverageStructMapParamValueObject>(NewObject(this, UCoverageStructMapParamValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Count a by-value FName-to-struct map and record Score 102 on ValueB.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs a TMap of FName to FMapParamValue
	 * @Return Items.Num() stored in NameStructValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountNameStructValue(TMap<FName, FMapParamValue> Items)
	{
		NameStructValueCount = Items.Num();
		FMapParamValue Found;
		NameStructValuePreserved =
			Items.Find(n"ValueB", Found)
			&& Found.Score == 102
			&& Found.Label == "NameValueB";
		return NameStructValueCount;
	}

	/**
	 * Count a const-in FName-to-struct map and record Score 112 on InB.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs a const &in TMap of FName to FMapParamValue
	 * @Return Items.Num() stored in NameStructInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountNameStructIn(const TMap<FName, FMapParamValue>&in Items)
	{
		NameStructInCount = Items.Num();
		FMapParamValue Found;
		NameStructInPreserved =
			Items.Find(n"InB", Found)
			&& Found.Score == 112
			&& Found.Label == "NameInB";
		return NameStructInCount;
	}

	/**
	 * Fill an out FName-to-struct map with OutA/OutB.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs an &out TMap of FName to FMapParamValue
	 * @Return Items with OutA 121 and OutB 122
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillNameStructOut(TMap<FName, FMapParamValue>&out Items)
	{
		Items.Add(n"OutA", MakeValue(121, "NameOutA"));
		Items.Add(n"OutB", MakeValue(122, "NameOutB"));
	}

	/**
	 * Mutate an inout FName-to-struct map, overwriting InoutA to 231.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs an &inout TMap of FName to FMapParamValue
	 * @Return NameStructInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateNameStructInout(TMap<FName, FMapParamValue>&inout Items)
	{
		FMapParamValue Found;
		NameStructInoutSawOriginal =
			Items.Find(n"InoutA", Found)
			&& Found.Score == 131
			&& Found.Label == "NameInoutA";
		Items.Add(n"InoutA", MakeValue(231, "NameInoutMutated"));
		Items.Add(n"InoutB", MakeValue(232, "NameInoutAdded"));
		NameStructInout = Items;

		FMapParamValue Mutated;
		NameStructInoutMutated =
			Items.Find(n"InoutA", Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "NameInoutMutated";
	}

	/**
	 * Return an FName-to-struct map preserving ReturnB Score 142.
	 *
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnA 141 and ReturnB 142
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FName, FMapParamValue> ReturnNameStruct()
	{
		TMap<FName, FMapParamValue> Items;
		Items.Add(n"ReturnA", MakeValue(141, "NameReturnA"));
		Items.Add(n"ReturnB", MakeValue(142, "NameReturnB"));

		FMapParamValue Found;
		NameStructReturnPreserved =
			Items.Find(n"ReturnB", Found)
			&& Found.Score == 142
			&& Found.Label == "NameReturnB";
		return Items;
	}

	/**
	 * Observe an empty FName-to-struct map count.
	 *
	 * @Kind Observe
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs CountNameStructValue of an empty map
	 * @Return true when the count is 0 and flags stay false
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool NameStructDefaultEmpty()
	{
		TMap<FName, FMapParamValue> Empty;
		if (CountNameStructValue(Empty) != 0)
		{
			return false;
		}
		if (NameStructValuePreserved)
		{
			return false;
		}
		return NameStructInout.Num() == 0;
	}

	/**
	 * Observe value/in/out/inout/return of TMap<FName,FStruct>.
	 *
	 * @Kind Observe
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs populated value/in/inout maps plus Fill and Return
	 * @Return true when counts are 2, Score 102/122/142 preserve, and inout mutates 231
	 */
	UFUNCTION()
	bool NameStructNominalMatrix()
	{
		TMap<FName, FMapParamValue> ValueItems;
		ValueItems.Add(n"ValueA", MakeValue(101, "NameValueA"));
		ValueItems.Add(n"ValueB", MakeValue(102, "NameValueB"));
		TMap<FName, FMapParamValue> InItems;
		InItems.Add(n"InA", MakeValue(111, "NameInA"));
		InItems.Add(n"InB", MakeValue(112, "NameInB"));
		TMap<FName, FMapParamValue> OutItems;
		FillNameStructOut(OutItems);
		TMap<FName, FMapParamValue> InoutItems;
		InoutItems.Add(n"InoutA", MakeValue(131, "NameInoutA"));
		MutateNameStructInout(InoutItems);
		TMap<FName, FMapParamValue> Returned = ReturnNameStruct();
		FMapParamValue Found;
		if (CountNameStructValue(ValueItems) != 2)
		{
			return false;
		}
		if (!NameStructValuePreserved)
		{
			return false;
		}
		if (CountNameStructIn(InItems) != 2)
		{
			return false;
		}
		if (!NameStructInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!OutItems.Find(n"OutB", Found))
		{
			return false;
		}
		if (Found.Score != 122)
		{
			return false;
		}
		if (!NameStructInoutSawOriginal)
		{
			return false;
		}
		if (!NameStructInoutMutated)
		{
			return false;
		}
		if (!NameStructReturnPreserved)
		{
			return false;
		}
		if (!Returned.Find(n"ReturnB", Found))
		{
			return false;
		}
		return Found.Score == 142;
	}

	/**
	 * Observe MakeObject of value 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.NameToStructMapParameterAndReturn
	 * @Inputs MakeObject(0)
	 * @Return 0 when the object is non-null, otherwise -1
	 * @Boundary zero object value
	 */
	UFUNCTION()
	int NameStructMakeObjectBoundary()
	{
		UCoverageStructMapParamValueObject Object = MakeObject(0);
		if (Object == nullptr)
		{
			return -1;
		}
		return Object.Value;
	}
}
