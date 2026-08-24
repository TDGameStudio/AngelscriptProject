// Theme: Feature.Delegates. Positive block 11: BeginPlay float-struct and object-struct executes.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8137-8220.
// Isolation=none: wrap the BeginPlay statements with float/object signals, MakeValue,
// MakeKeyObject, and handlers. Oracle: FloatStructValueResult 2; FloatOutB Score 622;
// ObjectOutB Key.Value 722. Extra: empty maps Num 0; 0.0f miss. DefaultSafe.

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

delegate int FFloatStructMapValueSignal(TMap<float, FDelegateKeyValueMapValue> Items);
delegate int FFloatStructMapInSignal(const TMap<float, FDelegateKeyValueMapValue>&in Items);
delegate void FFloatStructMapOutSignal(TMap<float, FDelegateKeyValueMapValue>&out Items);
delegate int FFloatStructMapInoutSignal(TMap<float, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<float, FDelegateKeyValueMapValue> FFloatStructMapReturnSignal();
delegate int FObjectStructMapValueSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> Items);
delegate int FObjectStructMapInSignal(const TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&in Items);
delegate void FObjectStructMapOutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&out Items);
delegate int FObjectStructMapInoutSignal(TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue>&inout Items);
delegate TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> FObjectStructMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FFloatStructMapValueSignal FloatStructValueSignal;
	UPROPERTY()
	FFloatStructMapInSignal FloatStructInSignal;
	UPROPERTY()
	FFloatStructMapOutSignal FloatStructOutSignal;
	UPROPERTY()
	FFloatStructMapInoutSignal FloatStructInoutSignal;
	UPROPERTY()
	FFloatStructMapReturnSignal FloatStructReturnSignal;
	UPROPERTY()
	FObjectStructMapValueSignal ObjectStructValueSignal;
	UPROPERTY()
	FObjectStructMapInSignal ObjectStructInSignal;
	UPROPERTY()
	FObjectStructMapOutSignal ObjectStructOutSignal;
	UPROPERTY()
	FObjectStructMapInoutSignal ObjectStructInoutSignal;
	UPROPERTY()
	FObjectStructMapReturnSignal ObjectStructReturnSignal;

	UPROPERTY()
	int FloatStructValueResult = 0;
	UPROPERTY()
	int FloatStructInResult = 0;
	UPROPERTY()
	int FloatStructInoutResult = 0;
	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructOutResult;
	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructInoutResultItems;
	UPROPERTY()
	TMap<float, FDelegateKeyValueMapValue> FloatStructReturnResult;
	UPROPERTY()
	bool FloatStructValuePreserved = false;
	UPROPERTY()
	bool FloatStructInPreserved = false;
	UPROPERTY()
	bool FloatStructOutPreserved = false;
	UPROPERTY()
	bool FloatStructInoutPreserved = false;
	UPROPERTY()
	bool FloatStructReturnPreserved = false;
	UPROPERTY()
	int ObjectStructValueResult = 0;
	UPROPERTY()
	int ObjectStructInResult = 0;
	UPROPERTY()
	int ObjectStructInoutResult = 0;
	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructOutResult;
	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInoutResultItems;
	UPROPERTY()
	TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructReturnResult;
	UPROPERTY()
	bool ObjectStructValuePreserved = false;
	UPROPERTY()
	bool ObjectStructInPreserved = false;
	UPROPERTY()
	bool ObjectStructOutPreserved = false;
	UPROPERTY()
	bool ObjectStructInoutPreserved = false;
	UPROPERTY()
	bool ObjectStructReturnPreserved = false;

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
		FloatStructValuePreserved = Items.Find(602.5f, Found) && Found.Score == 602 && Found.Label == "FloatValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleFloatStructIn(const TMap<float, FDelegateKeyValueMapValue>&in Items)
	{
		FDelegateKeyValueMapValue Found;
		FloatStructInPreserved = Items.Find(612.5f, Found) && Found.Score == 612 && Found.Label == "FloatInB";
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
		FloatStructInoutPreserved = Items.Find(631.5f, Mutated) && Mutated.Score == 731 && Mutated.Label == "FloatInoutMutated";
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
			if (Key != nullptr && Key.Value == 702 && Value.Score == 702 && Value.Label == "ObjectValueB")
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
			if (Key != nullptr && Key.Value == 712 && Value.Score == 712 && Value.Label == "ObjectInB")
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
			if (Key != nullptr && Key.Value == 731 && Value.Score == 831 && Value.Label == "ObjectInoutMutated")
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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FloatStructValueSignal.BindUFunction(this, n"HandleFloatStructValue");
		FloatStructInSignal.BindUFunction(this, n"HandleFloatStructIn");
		FloatStructOutSignal.BindUFunction(this, n"HandleFloatStructOut");
		FloatStructInoutSignal.BindUFunction(this, n"HandleFloatStructInout");
		FloatStructReturnSignal.BindUFunction(this, n"HandleFloatStructReturn");

		TMap<float, FDelegateKeyValueMapValue> FloatStructValueItems;
		FloatStructValueItems.Add(601.5f, MakeValue(601, "FloatValueA"));
		FloatStructValueItems.Add(602.5f, MakeValue(602, "FloatValueB"));
		FloatStructValueResult = FloatStructValueSignal.Execute(FloatStructValueItems);

		TMap<float, FDelegateKeyValueMapValue> FloatStructInItems;
		FloatStructInItems.Add(611.5f, MakeValue(611, "FloatInA"));
		FloatStructInItems.Add(612.5f, MakeValue(612, "FloatInB"));
		FloatStructInResult = FloatStructInSignal.Execute(FloatStructInItems);

		FloatStructOutSignal.Execute(FloatStructOutResult);
		FDelegateKeyValueMapValue FloatStructOutFound;
		FloatStructOutPreserved =
			FloatStructOutResult.Find(622.5f, FloatStructOutFound)
			&& FloatStructOutFound.Score == 622
			&& FloatStructOutFound.Label == "FloatOutB";

		FloatStructInoutResultItems.Add(631.5f, MakeValue(631, "FloatInoutA"));
		FloatStructInoutResult = FloatStructInoutSignal.Execute(FloatStructInoutResultItems);

		FloatStructReturnResult = FloatStructReturnSignal.Execute();
		FDelegateKeyValueMapValue FloatStructReturnFound;
		FloatStructReturnPreserved =
			FloatStructReturnResult.Find(642.5f, FloatStructReturnFound)
			&& FloatStructReturnFound.Score == 642
			&& FloatStructReturnFound.Label == "FloatReturnB";

		ObjectStructValueSignal.BindUFunction(this, n"HandleObjectStructValue");
		ObjectStructInSignal.BindUFunction(this, n"HandleObjectStructIn");
		ObjectStructOutSignal.BindUFunction(this, n"HandleObjectStructOut");
		ObjectStructInoutSignal.BindUFunction(this, n"HandleObjectStructInout");
		ObjectStructReturnSignal.BindUFunction(this, n"HandleObjectStructReturn");

		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructValueItems;
		ObjectStructValueItems.Add(MakeKeyObject(701), MakeValue(701, "ObjectValueA"));
		ObjectStructValueItems.Add(MakeKeyObject(702), MakeValue(702, "ObjectValueB"));
		ObjectStructValueResult = ObjectStructValueSignal.Execute(ObjectStructValueItems);

		TMap<UCoverageStructDelegateMapKeyObject, FDelegateKeyValueMapValue> ObjectStructInItems;
		ObjectStructInItems.Add(MakeKeyObject(711), MakeValue(711, "ObjectInA"));
		ObjectStructInItems.Add(MakeKeyObject(712), MakeValue(712, "ObjectInB"));
		ObjectStructInResult = ObjectStructInSignal.Execute(ObjectStructInItems);

		ObjectStructOutSignal.Execute(ObjectStructOutResult);
		ObjectStructOutPreserved = false;
		for (auto Element : ObjectStructOutResult)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 722
				&& Value.Score == 722
				&& Value.Label == "ObjectOutB")
			{
				ObjectStructOutPreserved = true;
			}
		}

		ObjectStructInoutResultItems.Add(MakeKeyObject(731), MakeValue(731, "ObjectInoutA"));
		ObjectStructInoutResult = ObjectStructInoutSignal.Execute(ObjectStructInoutResultItems);

		ObjectStructReturnResult = ObjectStructReturnSignal.Execute();
		ObjectStructReturnPreserved = false;
		for (auto Element : ObjectStructReturnResult)
		{
			UCoverageStructDelegateMapKeyObject Key = Element.GetKey();
			FDelegateKeyValueMapValue Value = Element.GetValue();
			if (Key != nullptr
				&& Key.Value == 742
				&& Value.Score == 742
				&& Value.Label == "ObjectReturnB")
			{
				ObjectStructReturnPreserved = true;
			}
		}
	}
}

int Observe_FloatStructValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_11 setup: required Actor is null");
	}
	return Actor.FloatStructValueResult;
}

int Observe_EmptyFloatMap_DefaultNum()
{
	TMap<float, FDelegateKeyValueMapValue> Items;
	return Items.Num();
}

bool Observe_KeyObject_NullBoundary()
{
	UCoverageStructDelegateMapKeyObject Key = nullptr;
	return Key == nullptr;
}
