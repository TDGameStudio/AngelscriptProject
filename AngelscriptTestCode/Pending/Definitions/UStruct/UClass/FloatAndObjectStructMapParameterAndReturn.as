/**
 * @version v1
 * @summary TMap of float to FStruct and UObject to FStruct as value/in/out/inout/return. Float 102.5 Score 102. Object key Value 202 Score 202. Empty 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TMap of float to FStruct and UObject to FStruct as value/in/out/inout/return. Float 102.5 Score 102. Object key Value 202 Score 202. Empty 0.
 * @topic Baseline
 */
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

	/**
	 * Build a primitive value from a score and label.
	 *
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
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
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
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
	 * Count a float-to-struct map by value and record Find(102.5) Score 102.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return FloatStructValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountFloatStructValue(TMap<float, FMapPrimitiveValue> Items)
	{
		FloatStructValueCount = Items.Num();
		FMapPrimitiveValue Found;
		FloatStructValuePreserved =
			Items.Find(102.5f, Found)
			&& Found.Score == 102
			&& Found.Label == "FloatValueB";
		return FloatStructValueCount;
	}

	/**
	 * Count a const float-to-struct map as &in and record Find(112.5) Score 112.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as const TMap<float, FMapPrimitiveValue>&in
	 * @Inputs Items
	 * @Return FloatStructInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountFloatStructIn(const TMap<float, FMapPrimitiveValue>&in Items)
	{
		FloatStructInCount = Items.Num();
		FMapPrimitiveValue Found;
		FloatStructInPreserved =
			Items.Find(112.5f, Found)
			&& Found.Score == 112
			&& Found.Label == "FloatInB";
		return FloatStructInCount;
	}

	/**
	 * Fill an &out float-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as TMap<float, FMapPrimitiveValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillFloatStructOut(TMap<float, FMapPrimitiveValue>&out Items)
	{
		Items.Add(121.5f, MakeValue(121, "FloatOutA"));
		Items.Add(122.5f, MakeValue(122, "FloatOutB"));
	}

	/**
	 * Mutate an &inout float-to-struct map, rewriting 131.5 to 231.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as TMap<float, FMapPrimitiveValue>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateFloatStructInout(TMap<float, FMapPrimitiveValue>&inout Items)
	{
		FMapPrimitiveValue Found;
		FloatStructInoutSawOriginal =
			Items.Find(131.5f, Found)
			&& Found.Score == 131
			&& Found.Label == "FloatInoutA";
		Items.Add(131.5f, MakeValue(231, "FloatInoutMutated"));
		Items.Add(132.5f, MakeValue(232, "FloatInoutAdded"));
		FloatStructInout = Items;

		FMapPrimitiveValue Mutated;
		FloatStructInoutMutated =
			Items.Find(131.5f, Mutated)
			&& Mutated.Score == 231
			&& Mutated.Label == "FloatInoutMutated";
	}

	/**
	 * Return a float-to-struct map and record Find(142.5) Score 142.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Inputs none
	 * @Return 141.5/142.5 entries
	 */
	UFUNCTION(BlueprintCallable)
	TMap<float, FMapPrimitiveValue> ReturnFloatStruct()
	{
		TMap<float, FMapPrimitiveValue> Items;
		Items.Add(141.5f, MakeValue(141, "FloatReturnA"));
		Items.Add(142.5f, MakeValue(142, "FloatReturnB"));

		FMapPrimitiveValue Found;
		FloatStructReturnPreserved =
			Items.Find(142.5f, Found)
			&& Found.Score == 142
			&& Found.Label == "FloatReturnB";
		return Items;
	}

	/**
	 * Count an object-to-struct map by value and record key Value 202 Score 202.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return ObjectStructValueCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountObjectStructValue(TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> Items)
	{
		ObjectStructValueCount = Items.Num();
		for (auto Element : Items)
		{
			UCoverageStructMapPrimitiveKeyObject Key = Element.GetKey();
			FMapPrimitiveValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 202 && Value.Score == 202 && Value.Label == "ObjectValueB")
			{
				ObjectStructValuePreserved = true;
			}
		}
		return ObjectStructValueCount;
	}

	/**
	 * Count a const object-to-struct map as &in and record key Value 212 Score 212.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as const TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&in
	 * @Inputs Items
	 * @Return ObjectStructInCount
	 */
	UFUNCTION(BlueprintCallable)
	int CountObjectStructIn(const TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&in Items)
	{
		ObjectStructInCount = Items.Num();
		for (auto Element : Items)
		{
			UCoverageStructMapPrimitiveKeyObject Key = Element.GetKey();
			FMapPrimitiveValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 212 && Value.Score == 212 && Value.Label == "ObjectInB")
			{
				ObjectStructInPreserved = true;
			}
		}
		return ObjectStructInCount;
	}

	/**
	 * Fill an &out object-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void FillObjectStructOut(TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&out Items)
	{
		Items.Add(MakeObjectKey(221), MakeValue(221, "ObjectOutA"));
		Items.Add(MakeObjectKey(222), MakeValue(222, "ObjectOutB"));
	}

	/**
	 * Mutate an &inout object-to-struct map, rewriting key 231 to Score 331.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Param Items Map received as TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&inout
	 * @Inputs Items
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable)
	void MutateObjectStructInout(TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&inout Items)
	{
		for (auto Element : Items)
		{
			UCoverageStructMapPrimitiveKeyObject Key = Element.GetKey();
			FMapPrimitiveValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 231 && Value.Score == 231 && Value.Label == "ObjectInoutA")
			{
				ObjectStructInoutSawOriginal = true;
				Element.SetValue(MakeValue(331, "ObjectInoutMutated"));
			}
		}
		Items.Add(MakeObjectKey(232), MakeValue(332, "ObjectInoutAdded"));
		ObjectStructInout = Items;

		for (auto Element : ObjectStructInout)
		{
			UCoverageStructMapPrimitiveKeyObject Key = Element.GetKey();
			FMapPrimitiveValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 231 && Value.Score == 331 && Value.Label == "ObjectInoutMutated")
			{
				ObjectStructInoutMutated = true;
			}
		}
	}

	/**
	 * Return an object-to-struct map and record key Value 242 Score 242.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Inputs none
	 * @Return keys 241/242
	 */
	UFUNCTION(BlueprintCallable)
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ReturnObjectStruct()
	{
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> Items;
		Items.Add(MakeObjectKey(241), MakeValue(241, "ObjectReturnA"));
		Items.Add(MakeObjectKey(242), MakeValue(242, "ObjectReturnB"));

		for (auto Element : Items)
		{
			UCoverageStructMapPrimitiveKeyObject Key = Element.GetKey();
			FMapPrimitiveValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 242 && Value.Score == 242 && Value.Label == "ObjectReturnB")
			{
				ObjectStructReturnPreserved = true;
			}
		}
		return Items;
	}

	/**
	 * Observe empty float and object map counts.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Inputs empty float and object maps
	 * @Return true when both counts are 0 and flags are false
	 * @Boundary empty maps
	 */
	UFUNCTION()
	bool FloatObjectStructDefaultEmpty()
	{
		TMap<float, FMapPrimitiveValue> EmptyFloat;
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> EmptyObject;
		if (CountFloatStructValue(EmptyFloat) != 0)
		{
			return false;
		}
		if (CountObjectStructValue(EmptyObject) != 0)
		{
			return false;
		}
		if (FloatStructValuePreserved)
		{
			return false;
		}
		return !ObjectStructValuePreserved;
	}

	/**
	 * Observe nominal float and object struct maps.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Inputs populated float and object maps
	 * @Return true when float 102.5 Score 102 and object key 202 Score 202
	 */
	UFUNCTION()
	bool FloatObjectStructNominalMatrix()
	{
		TMap<float, FMapPrimitiveValue> FloatValue;
		FloatValue.Add(101.5f, MakeValue(101, "FloatValueA"));
		FloatValue.Add(102.5f, MakeValue(102, "FloatValueB"));
		TMap<float, FMapPrimitiveValue> FloatIn;
		FloatIn.Add(112.5f, MakeValue(112, "FloatInB"));
		TMap<float, FMapPrimitiveValue> FloatOut;
		FillFloatStructOut(FloatOut);
		TMap<float, FMapPrimitiveValue> FloatInout;
		FloatInout.Add(131.5f, MakeValue(131, "FloatInoutA"));
		MutateFloatStructInout(FloatInout);
		TMap<float, FMapPrimitiveValue> FloatReturned = ReturnFloatStruct();

		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectValue;
		ObjectValue.Add(MakeObjectKey(201), MakeValue(201, "ObjectValueA"));
		ObjectValue.Add(MakeObjectKey(202), MakeValue(202, "ObjectValueB"));
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectIn;
		ObjectIn.Add(MakeObjectKey(212), MakeValue(212, "ObjectInB"));
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectOut;
		FillObjectStructOut(ObjectOut);
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectInout;
		ObjectInout.Add(MakeObjectKey(231), MakeValue(231, "ObjectInoutA"));
		MutateObjectStructInout(ObjectInout);
		TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectReturned = ReturnObjectStruct();
		if (CountFloatStructValue(FloatValue) != 2)
		{
			return false;
		}
		if (!FloatStructValuePreserved)
		{
			return false;
		}
		if (CountFloatStructIn(FloatIn) != 1)
		{
			return false;
		}
		if (!FloatStructInPreserved)
		{
			return false;
		}
		if (FloatOut.Num() != 2)
		{
			return false;
		}
		if (!FloatStructInoutMutated)
		{
			return false;
		}
		if (!FloatStructReturnPreserved)
		{
			return false;
		}
		if (FloatReturned.Num() != 2)
		{
			return false;
		}
		if (CountObjectStructValue(ObjectValue) != 2)
		{
			return false;
		}
		if (!ObjectStructValuePreserved)
		{
			return false;
		}
		if (CountObjectStructIn(ObjectIn) != 1)
		{
			return false;
		}
		if (!ObjectStructInPreserved)
		{
			return false;
		}
		if (ObjectOut.Num() != 2)
		{
			return false;
		}
		if (!ObjectStructInoutSawOriginal)
		{
			return false;
		}
		if (!ObjectStructReturnPreserved)
		{
			return false;
		}
		return ObjectReturned.Num() == 2;
	}

	/**
	 * Observe CountFloatStructValue of a zero-float key.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FloatAndObjectStructMapParameterAndReturn
	 * @Inputs 0.0f -> Score 0 empty label
	 * @Return 1
	 * @Boundary zero float key
	 */
	UFUNCTION()
	int FloatObjectStructZeroFloatBoundary()
	{
		TMap<float, FMapPrimitiveValue> Items;
		Items.Add(0.0f, MakeValue(0, ""));
		return CountFloatStructValue(Items);
	}
}
/** @end */
