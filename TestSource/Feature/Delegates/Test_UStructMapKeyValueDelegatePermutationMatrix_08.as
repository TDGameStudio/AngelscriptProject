// Theme: Feature.Delegates. Positive block 8: float-struct and object-struct handlers.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 7753-7898.
// Isolation=none: wrap HandleFloatStruct* / HandleObjectStruct* with object/value types.
// Oracle: HandleFloatStructValue preserves 602.5f Score 602; HandleObjectStructValue
// Key.Value 702. Extra: empty maps Num 0; 0.0f miss; null key skip. DefaultSafe.

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

	FDelegateKeyValueMapValue MakeValue(int Score, FString Label)
	{
		FDelegateKeyValueMapValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructDelegateMapKeyObject MakeKeyObject(int Value)
	{
		UCoverageStructDelegateMapKeyObject Object = Cast<UCoverageStructDelegateMapKeyObject>(NewObject(this, UCoverageStructDelegateMapKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

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

	UFUNCTION()
	void HandleFloatStructOut(TMap<float, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(621.5f, MakeValue(621, "FloatOutA"));
		Items.Add(622.5f, MakeValue(622, "FloatOutB"));
	}

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

	UFUNCTION()
	TMap<float, FDelegateKeyValueMapValue> HandleFloatStructReturn()
	{
		TMap<float, FDelegateKeyValueMapValue> Items;
		Items.Add(641.5f, MakeValue(641, "FloatReturnA"));
		Items.Add(642.5f, MakeValue(642, "FloatReturnB"));
		return Items;
	}

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

	UFUNCTION()
	void HandleObjectStructOut(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items)
	{
		Items.Add(MakeKeyObject(721), MakeValue(721, "ObjectOutA"));
		Items.Add(MakeKeyObject(722), MakeValue(722, "ObjectOutB"));
	}

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

	UFUNCTION()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> HandleObjectStructReturn()
	{
		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items;
		Items.Add(MakeKeyObject(741), MakeValue(741, "ObjectReturnA"));
		Items.Add(MakeKeyObject(742), MakeValue(742, "ObjectReturnB"));
		return Items;
	}
}

int Observe_EmptyFloatMap_DefaultNum()
{
	TMap<float, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_ZeroFloatKey_MissingBoundary()
{
	TMap<float, FDelegateKeyValueMapValue> Items;
	FDelegateKeyValueMapValue Found;
	return !Items.Find(0.0f, Found) && Found.Score == 0;
}

bool Observe_KeyObject_NullBoundary()
{
	UCoverageStructDelegateMapKeyObject Key = nullptr;
	return Key == nullptr;
}
