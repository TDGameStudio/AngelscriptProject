/**
 * @version v1
 * @summary TMap of bool to FStruct as value/in/out/inout/return. Find(false) Score 102 Label BoolValueFalse. Inout mutates true to 231. Empty count 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of bool to FStruct as value/in/out/inout/return. Find(false) Score 102 Label BoolValueFalse. Inout mutates true to 231. Empty count 0.
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
	 * @Covers UStruct.BoolStructMapParameterAndReturn
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
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

USTRUCT(BlueprintType)
struct FMapPrimitiveValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class UCoverageStructMapPrimitiveKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

UCLASS()
class ACoverageStructMapPrimitiveMatrixActor : AActor
{
	UPROPERTY()
	int BoolStructValueCount = 0;

	UPROPERTY()
	int BoolStructInCount = 0;

	UPROPERTY()
	TMap<bool, FMapPrimitiveValue> BoolStructInout;

	UPROPERTY()
	bool BoolStructValuePreserved = false;

	UPROPERTY()
	bool BoolStructInPreserved = false;

	UPROPERTY()
	bool BoolStructInoutSawOriginal = false;

	UPROPERTY()
	bool BoolStructInoutMutated = false;

	UPROPERTY()
	bool BoolStructReturnPreserved = false;

	UPROPERTY()
	int FloatStructValueCount = 0;

	UPROPERTY()
	int FloatStructInCount = 0;

	UPROPERTY()
	TMap<float, FMapPrimitiveValue> FloatStructInout;

	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructInoutSawOriginal = false;

	UPROPERTY()
	bool FloatStructInoutMutated = false;

	UPROPERTY()
	bool FloatStructReturnPreserved = false;

	UPROPERTY()
	int ObjectStructValueCount = 0;

	UPROPERTY()
	int ObjectStructInCount = 0;

	UPROPERTY()
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectStructInout;

	UPROPERTY()
	bool ObjectStructValuePreserved = false;

	UPROPERTY()
	bool ObjectStructInPreserved = false;

	UPROPERTY()
	bool ObjectStructInoutSawOriginal = false;

	UPROPERTY()
	bool ObjectStructInoutMutated = false;

	UPROPERTY()
	bool ObjectStructReturnPreserved = false;

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
	 * Build a primitive key from an id and tag.
	 *
	 * @Covers UStruct.BoolStructMapParameterAndReturn
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
	 * Build a primitive value from a score and label.
	 *
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FMapPrimitiveValue MakeValue(int Score, FString Label)
	{
		FMapPrimitiveValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Build a UObject map key with Value.
	 *
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs Value
	 * @Return a new UCoverageStructMapPrimitiveKeyObject
	 * @Param Value the object Value
	 */
	UCoverageStructMapPrimitiveKeyObject MakeObjectKey(int Value)
	{
		UCoverageStructMapPrimitiveKeyObject Object = Cast<UCoverageStructMapPrimitiveKeyObject>(NewObject(this, UCoverageStructMapPrimitiveKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Count a bool-to-struct map by value and record Find(false) Score 102.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return BoolStructValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountBoolStructValue(TMap<bool, FMapPrimitiveValue> Items)
	{
		BoolStructValueCount = Items.Num();
		FMapPrimitiveValue Found;
		BoolStructValuePreserved =
			Items.Find(false, Found)
			&& Found.Score == 102
			&& Found.Label == "BoolValueFalse";
		return BoolStructValueCount;
	}

	/**
	 * Count a const bool-to-struct map as &in and record Find(true) Score 111.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Param Items Map received as const TMap<bool, FMapPrimitiveValue>&in
	 * @Inputs Items
	 * @Return BoolStructInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountBoolStructIn(const TMap<bool, FMapPrimitiveValue>&in Items)
	{
		BoolStructInCount = Items.Num();
		FMapPrimitiveValue Found;
		BoolStructInPreserved =
			Items.Find(true, Found)
			&& Found.Score == 111
			&& Found.Label == "BoolInTrue";
		return BoolStructInCount;
	}

	/**
	 * Fill an &out bool-to-struct map with true/false values.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Param Items Map received as TMap<bool, FMapPrimitiveValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillBoolStructOut(TMap<bool, FMapPrimitiveValue>&out Items)
	{
		Items.Add(true, MakeValue(121, "BoolOutTrue"));
		Items.Add(false, MakeValue(122, "BoolOutFalse"));
	}

	/**
	 * Mutate an &inout bool-to-struct map, rewriting true to 231.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Param Items Map received as TMap<bool, FMapPrimitiveValue>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateBoolStructInout(TMap<bool, FMapPrimitiveValue>&inout Items)
	{
		FMapPrimitiveValue Found;
		BoolStructInoutSawOriginal =
			Items.Find(true, Found)
			&& Found.Score == 131
			&& Found.Label == "BoolInoutTrue";
		Items.Add(true, MakeValue(231, "BoolInoutMutated"));
		Items.Add(false, MakeValue(232, "BoolInoutAdded"));
		BoolStructInout = Items;

		FMapPrimitiveValue Mutated;
		BoolStructInoutMutated =
			Items.Find(true, Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "BoolInoutMutated";
	}

	/**
	 * Return a bool-to-struct map and record Find(false) Score 142.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs none
	 * @Return true/false entries Score 141/142
	 */
	UFUNCTION(BlueprintCallable)
	TMap<bool, FMapPrimitiveValue> ReturnBoolStruct()
	{
		TMap<bool, FMapPrimitiveValue> Items;
		Items.Add(true, MakeValue(141, "BoolReturnTrue"));
		Items.Add(false, MakeValue(142, "BoolReturnFalse"));

		FMapPrimitiveValue Found;
		BoolStructReturnPreserved =
			Items.Find(false, Found)
			&& Found.Score == 142
			&& Found.Label == "BoolReturnFalse";
		return Items;
	}

	/**
	 * Observe empty bool-to-struct counts and default flags.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs empty map
	 * @Return true when count 0, flags false, and FloatStructValueCount 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool BoolStructDefaultEmpty()
	{
		TMap<bool, FMapPrimitiveValue> Empty;
		if (CountBoolStructValue(Empty) != 0)
		{
			return false;
		}
		if (BoolStructValuePreserved)
		{
			return false;
		}
		if (BoolStructInout.Num() != 0)
		{
			return false;
		}
		return FloatStructValueCount == 0;
	}

	/**
	 * Observe nominal bool-to-struct value/in/out/inout/return.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs populated bool maps
	 * @Return true when Find(false) Score 102, inout 231, return 142
	 */
	UFUNCTION()
	bool BoolStructNominalMatrix()
	{
		TMap<bool, FMapPrimitiveValue> ValueItems;
		ValueItems.Add(true, MakeValue(101, "BoolValueTrue"));
		ValueItems.Add(false, MakeValue(102, "BoolValueFalse"));
		TMap<bool, FMapPrimitiveValue> InItems;
		InItems.Add(true, MakeValue(111, "BoolInTrue"));
		TMap<bool, FMapPrimitiveValue> OutItems;
		FillBoolStructOut(OutItems);
		TMap<bool, FMapPrimitiveValue> InoutItems;
		InoutItems.Add(true, MakeValue(131, "BoolInoutTrue"));
		MutateBoolStructInout(InoutItems);
		TMap<bool, FMapPrimitiveValue> Returned = ReturnBoolStruct();
		FMapPrimitiveValue Found;
		if (CountBoolStructValue(ValueItems) != 2)
		{
			return false;
		}
		if (!BoolStructValuePreserved)
		{
			return false;
		}
		if (CountBoolStructIn(InItems) != 1)
		{
			return false;
		}
		if (!BoolStructInPreserved)
		{
			return false;
		}
		if (OutItems.Num() != 2)
		{
			return false;
		}
		if (!BoolStructInoutSawOriginal)
		{
			return false;
		}
		if (!BoolStructInoutMutated)
		{
			return false;
		}
		if (!BoolStructReturnPreserved)
		{
			return false;
		}
		if (!Returned.Find(false, Found))
		{
			return false;
		}
		return Found.Score == 142;
	}

	/**
	 * Observe Find(false) on a single-entry map.
	 *
	 * @Kind Observe
	 * @Covers UStruct.BoolStructMapParameterAndReturn
	 * @Inputs false -> Score 102 Label BoolValueFalse
	 * @Return true when count 1 and BoolStructValuePreserved
	 * @Boundary false key
	 */
	UFUNCTION()
	bool BoolStructFalseKeyBoundary()
	{
		TMap<bool, FMapPrimitiveValue> Items;
		Items.Add(false, MakeValue(102, "BoolValueFalse"));
		if (CountBoolStructValue(Items) != 1)
		{
			return false;
		}
		return BoolStructValuePreserved;
	}
}
/** @end */
