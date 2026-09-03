/**
 * Float-struct and object-struct handlers. HandleFloatStructValue preserves
 * 602.5f Score 602. HandleObjectStructValue Key.Value 702. Empty maps Num 0.
 * 0.0f miss. Null key skip.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.MapKeyValueFloatStructAndObjectStructHandlers
 * @Harness UClass
 * @Tag Feature.Delegates.MapKeyValueFloatStructAndObjectStructHandlers
 * @Provenance Theme: Feature.Delegates. Positive block 8: float-struct and object-struct handlers.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7753-7898.
 * @Provenance Isolation=none: wrap HandleFloatStruct* / HandleObjectStruct* with object/value types.
 * @Provenance Oracle: HandleFloatStructValue preserves 602.5f Score 602; HandleObjectStructValue
 * @Provenance Key.Value 702. Extra: empty maps Num 0; 0.0f miss; null key skip. DefaultSafe.
 */

UCLASS()
class UCoverageStructDelegateMapKeyObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapValue
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	bool FloatStructValuePreserved = false;

	UPROPERTY()
	bool FloatStructInPreserved = false;

	UPROPERTY()
	bool FloatStructInoutPreserved = false;

	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructInoutResultItems;

	UPROPERTY()
	bool ObjectStructValuePreserved = false;

	UPROPERTY()
	bool ObjectStructInPreserved = false;

	UPROPERTY()
	bool ObjectStructInoutPreserved = false;

	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInoutResultItems;

	/**
	 * Build a map value from a score and label.
	 *
	 * @Covers Delegates.MapKeyValueFloatStructAndObjectStructHandlers
	 * @Inputs Score and Label
	 * @Return a value holding those fields
	 * @Param Score the score
	 * @Param Label the label
	 */
	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	/**
	 * Build a UObject map key with Value.
	 *
	 * @Covers Delegates.MapKeyValueFloatStructAndObjectStructHandlers
	 * @Inputs Value
	 * @Return a new UCoverageStructDelegateMapKeyObject
	 * @Param Value the object Value
	 */
	UCoverageStructDelegateMapKeyObject MakeKeyObject(int Value)
	{
		UCoverageStructDelegateMapKeyObject Object = Cast<UCoverageStructDelegateMapKeyObject>(NewObject(this, UCoverageStructDelegateMapKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	/**
	 * Count a float-to-struct map by value and record Find 602.5 Score 602.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleFloatStructValue(TMap<float, FDelegateKeyValueMapValue> Items)
	{
		FDelegateKeyValueMapValue Found;
		FloatStructValuePreserved =
			Items.Find(602.5f, Found)
			&& Found.Score == 602
			&& Found.Label == "FloatValueB";
		return Items.Num();
	}

	/**
	 * Count a const float-to-struct map as &in and record Find 612.5 Score 612.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<float, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 30
	 */
	UFUNCTION()
	int HandleFloatStructIn(const TMap<float, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		FloatStructInPreserved =
			Items.Find(612.5f, Found)
			&& Found.Score == 612
			&& Found.Label == "FloatInB";
		return Items.Num() + 30;
	}

	/**
	 * Fill an &out float-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<float, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleFloatStructOut(TMap<float, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(621.5f, MakeValue(621, "FloatOutA"));
		Items.Add(622.5f, MakeValue(622, "FloatOutB"));
	}

	/**
	 * Mutate an &inout float-to-struct map, rewriting 631.5 to Score 731.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<float, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + Mutated.Score
	 */
	UFUNCTION()
	int HandleFloatStructInout(TMap<float, FDelegateKeyValueMapValue>&inout Items)
	{
		FDelegateKeyValueMapValue Found;
		if (Items.Find(631.5f, Found))
		{
			Found.Score += 100;
			Found.Label = "FloatInoutMutated";
			Items.Add(631.5f, Found);
		}
		Items.Add(632.5f, MakeValue(632, "FloatInoutAdded"));
		FloatStructInoutResultItems = Items;
		FDelegateKeyValueMapValue Mutated;
		FloatStructInoutPreserved =
			Items.Find(631.5f, Mutated)
			&& Mutated.Score == 731
			&& Mutated.Label == "FloatInoutMutated";
		return Items.Num() + Mutated.Score;
	}

	/**
	 * Return a float-to-struct map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return 641.5/642.5
	 */
	UFUNCTION()
	TMap<float, FDelegateKeyValueMapValue> HandleFloatStructReturn()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		Items.Add(641.5f, MakeValue(641, "FloatReturnA"));
		Items.Add(642.5f, MakeValue(642, "FloatReturnB"));
		return Items;
	}

	/**
	 * Count an object-to-struct map by value and record key Value 702 Score 702.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received by value
	 * @Inputs Items
	 * @Return Items.Num()
	 */
	UFUNCTION()
	int HandleObjectStructValue(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items)
	{
		ObjectStructValuePreserved = false;
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 702
				&& Value.Score == 702
				&& Value.Label == "ObjectValueB")
			{
				ObjectStructValuePreserved = true;
			}
		}
		return Items.Num();
	}

	/**
	 * Count a const object-to-struct map as &in and record key Value 712 Score 712.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in
	 * @Inputs Items
	 * @Return Items.Num() + 90
	 */
	UFUNCTION()
	int HandleObjectStructIn(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items)
	{
		ObjectStructInPreserved = false;
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 712
				&& Value.Score == 712
				&& Value.Label == "ObjectInB")
			{
				ObjectStructInPreserved = true;
			}
		}
		return Items.Num() + 90;
	}

	/**
	 * Fill an &out object-to-struct map with two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out
	 * @Inputs empty Items
	 * @Return void
	 */
	UFUNCTION()
	void HandleObjectStructOut(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(MakeKeyObject(721), MakeValue(721, "ObjectOutA"));
		Items.Add(MakeKeyObject(722), MakeValue(722, "ObjectOutB"));
	}

	/**
	 * Mutate an &inout object-to-struct map, rewriting key 731 to Score 831.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Items Map received as TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout
	 * @Inputs Items
	 * @Return Items.Num() + 100
	 */
	UFUNCTION()
	int HandleObjectStructInout(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items)
	{
		for (auto Element : Items)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr && Key.Value == 731)
			{
				Value.Score += 100;
				Value.Label = "ObjectInoutMutated";
				Element.SetValue(Value);
			}
		}
		Items.Add(MakeKeyObject(732), MakeValue(732, "ObjectInoutAdded"));
		ObjectStructInoutResultItems = Items;
		ObjectStructInoutPreserved = false;
		for (auto Element : ObjectStructInoutResultItems)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 731
				&& Value.Score == 831
				&& Value.Label == "ObjectInoutMutated")
			{
				ObjectStructInoutPreserved = true;
			}
		}
		return Items.Num() + 100;
	}

	/**
	 * Return an object-to-struct map of two keys.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return keys 741/742
	 */
	UFUNCTION()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> HandleObjectStructReturn()
	{
		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items;
		Items.Add(MakeKeyObject(741), MakeValue(741, "ObjectReturnA"));
		Items.Add(MakeKeyObject(742), MakeValue(742, "ObjectReturnB"));
		return Items;
	}

	/**
	 * Observe empty float-to-struct map Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty map
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int EmptyFloatMapDefaultNum()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		return Items.Num();
	}

	/**
	 * Observe Find of 0.0f on an empty map.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty map
	 * @Return true when Find misses and Score stays 0
	 * @Boundary 0.0f miss
	 */
	UFUNCTION()
	bool ZeroFloatKeyMissingBoundary()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		FDelegateKeyValueMapValue Found;
		if (Items.Find(0.0f, Found))
		{
			return false;
		}
		return Found.Score == 0;
	}

	/**
	 * Observe a null object key.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs nullptr
	 * @Return true when the key is null
	 * @Boundary null key
	 */
	UFUNCTION()
	bool KeyObjectNullBoundary()
	{
		UCoverageStructDelegateMapKeyObject Key = nullptr;
		return Key == nullptr;
	}
}
