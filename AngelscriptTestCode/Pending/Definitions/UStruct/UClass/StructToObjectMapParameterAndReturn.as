/**
 * @version v1
 * @summary TMap of FStruct to UObject as value/in/out/inout/return. C++ checks ValueB object Value 502 and inout mutation to 631. A null object is not preserved.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of FStruct to UObject as value/in/out/inout/return. C++ checks ValueB object Value 502 and inout mutation to 631. A null object is not preserved.
 * @topic Baseline
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
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
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
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
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
	int StructObjectValueCount = 0;

	UPROPERTY()
	int StructObjectInCount = 0;

	UPROPERTY()
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> StructObjectInout;

	UPROPERTY()
	bool StructObjectValuePreserved = false;

	UPROPERTY()
	bool StructObjectInPreserved = false;

	UPROPERTY()
	bool StructObjectInoutSawOriginal = false;

	UPROPERTY()
	bool StructObjectInoutMutated = false;

	UPROPERTY()
	bool StructObjectReturnPreserved = false;

	/**
	 * Build a map key from an id and tag.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
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
	 * Build a map-value object with the given Value.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
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
	 * Count a by-value struct-to-object map and record ValueB 502.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs a TMap of FMapParamKey to UCoverageStructMapParamValueObject
	 * @Return Items.Num() stored in StructObjectValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructObjectValue(TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items)
	{
		StructObjectValueCount = Items.Num();
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectValuePreserved =
			Items.Find(MakeKey(501, n"ValueB"), Found)
			&& Found != nullptr
			&& Found.Value == 502;
		return StructObjectValueCount;
	}

	/**
	 * Count a const-in struct-to-object map and record InB 512.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs a const &in TMap of FMapParamKey to UCoverageStructMapParamValueObject
	 * @Return Items.Num() stored in StructObjectInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountStructObjectIn(const TMap<FMapParamKey, UCoverageStructMapParamValueObject>&in Items)
	{
		StructObjectInCount = Items.Num();
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectInPreserved =
			Items.Find(MakeKey(511, n"InB"), Found)
			&& Found != nullptr
			&& Found.Value == 512;
		return StructObjectInCount;
	}

	/**
	 * Fill an out struct-to-object map with OutA 521 and OutB 522.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs an &out TMap of FMapParamKey to UCoverageStructMapParamValueObject
	 * @Return Items with two objects
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillStructObjectOut(TMap<FMapParamKey, UCoverageStructMapParamValueObject>&out Items)
	{
		Items.Add(MakeKey(520, n"OutA"), MakeObject(521));
		Items.Add(MakeKey(521, n"OutB"), MakeObject(522));
	}

	/**
	 * Mutate an inout struct-to-object map, overwriting InoutA to 631.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs an &inout TMap of FMapParamKey to UCoverageStructMapParamValueObject
	 * @Return StructObjectInout copied from Items after mutation
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateStructObjectInout(TMap<FMapParamKey, UCoverageStructMapParamValueObject>&inout Items)
	{
		FMapParamKey Existing = MakeKey(530, n"InoutA");
		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectInoutSawOriginal =
			Items.Find(Existing, Found)
			&& Found != nullptr
			&& Found.Value == 531;
		Items.Add(Existing, MakeObject(631));
		Items.Add(MakeKey(531, n"InoutB"), MakeObject(632));
		StructObjectInout = Items;

		UCoverageStructMapParamValueObject Mutated = nullptr;
		StructObjectInoutMutated =
			Items.Find(Existing, Mutated)
			&& Mutated != nullptr
			&& Mutated.Value == 631;
	}

	/**
	 * Return a struct-to-object map preserving ReturnB 542.
	 *
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs none
	 * @Return a TMap with ReturnA 541 and ReturnB 542
	 */
	UFUNCTION(BlueprintCallable)
	TMap<FMapParamKey, UCoverageStructMapParamValueObject> ReturnStructObject()
	{
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items;
		Items.Add(MakeKey(540, n"ReturnA"), MakeObject(541));
		Items.Add(MakeKey(541, n"ReturnB"), MakeObject(542));

		UCoverageStructMapParamValueObject Found = nullptr;
		StructObjectReturnPreserved =
			Items.Find(MakeKey(541, n"ReturnB"), Found)
			&& Found != nullptr
			&& Found.Value == 542;
		return Items;
	}

	/**
	 * Observe an empty struct-to-object map count.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs CountStructObjectValue of an empty map
	 * @Return true when the count is 0 and flags stay false
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool StructObjectDefaultEmpty()
	{
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> Empty;
		if (CountStructObjectValue(Empty) != 0)
		{
			return false;
		}
		if (StructObjectValuePreserved)
		{
			return false;
		}
		return StructObjectInout.Num() == 0;
	}

	/**
	 * Observe value/in/out/inout/return of TMap<FStruct,UObject>.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs populated value/in/inout maps plus Fill and Return
	 * @Return true when counts are 2, Value 502 preserves, and inout mutates 631
	 */
	UFUNCTION()
	bool StructObjectNominalMatrix()
	{
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> ValueItems;
		ValueItems.Add(MakeKey(500, n"ValueA"), MakeObject(501));
		ValueItems.Add(MakeKey(501, n"ValueB"), MakeObject(502));
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> InItems;
		InItems.Add(MakeKey(510, n"InA"), MakeObject(511));
		InItems.Add(MakeKey(511, n"InB"), MakeObject(512));
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> OutItems;
		FillStructObjectOut(OutItems);
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> InoutItems;
		InoutItems.Add(MakeKey(530, n"InoutA"), MakeObject(531));
		MutateStructObjectInout(InoutItems);
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> Returned = ReturnStructObject();
		if (CountStructObjectValue(ValueItems) != 2)
		{
			return false;
		}
		if (!StructObjectValuePreserved)
		{
			return false;
		}
		if (CountStructObjectIn(InItems) != 2)
		{
			return false;
		}
		if (!StructObjectInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!StructObjectInoutSawOriginal)
		{
			return false;
		}
		if (!StructObjectInoutMutated)
		{
			return false;
		}
		if (!StructObjectReturnPreserved)
		{
			return false;
		}
		return Returned.Num() == 2;
	}

	/**
	 * Observe that a null object value is not preserved.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructToObjectMapParameterAndReturn
	 * @Inputs Add of a nullptr ValueB
	 * @Return true when the count is 1 and ValuePreserved is false
	 * @Boundary null object
	 */
	UFUNCTION()
	bool StructObjectNullValueBoundary()
	{
		TMap<FMapParamKey, UCoverageStructMapParamValueObject> Items;
		Items.Add(MakeKey(501, n"ValueB"), nullptr);
		if (CountStructObjectValue(Items) != 1)
		{
			return false;
		}
		return !StructObjectValuePreserved;
	}
}
/** @end */
