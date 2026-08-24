// Theme: Definitions.UStruct. Positive block 3: TMap<float,FStruct> and TMap<UObject,FStruct>.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapPrimitiveKeyValueParameterAndReturnMatrix lines 13802-13953.
// Isolation=none: complete program wrapping CountFloatStruct* / CountObjectStruct*.
// Oracle: float 102.5 Score 102; object key Value 202 Score 202. Extra: empty 0. DefaultSafe.

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

	FMapPrimitiveValue MakeValue(int Score, FString Label)
	{
		FMapPrimitiveValue Value;
		Value.Score = Score;
		Value.Label = Label;
		return Value;
	}

	UCoverageStructMapPrimitiveKeyObject MakeObjectKey(int Value)
	{
		UCoverageStructMapPrimitiveKeyObject Object = Cast<UCoverageStructMapPrimitiveKeyObject>(NewObject(this, UCoverageStructMapPrimitiveKeyObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

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

	UFUNCTION(BlueprintCallable)
	void FillFloatStructOut(TMap<float, FMapPrimitiveValue>&out Items)
	{
		Items.Add(121.5f, MakeValue(121, "FloatOutA"));
		Items.Add(122.5f, MakeValue(122, "FloatOutB"));
	}

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

	UFUNCTION(BlueprintCallable)
	void FillObjectStructOut(TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue>&out Items)
	{
		Items.Add(MakeObjectKey(221), MakeValue(221, "ObjectOutA"));
		Items.Add(MakeObjectKey(222), MakeValue(222, "ObjectOutB"));
	}

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
}

bool Observe_FloatObjectStruct_DefaultEmpty(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<float, FMapPrimitiveValue> EmptyFloat;
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> EmptyObject;
	return Actor.CountFloatStructValue(EmptyFloat) == 0
		&& Actor.CountObjectStructValue(EmptyObject) == 0
		&& !Actor.FloatStructValuePreserved
		&& !Actor.ObjectStructValuePreserved;
}

bool Observe_FloatObjectStruct_NominalMatrix(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<float, FMapPrimitiveValue> FloatValue;
	FloatValue.Add(101.5f, Actor.MakeValue(101, "FloatValueA"));
	FloatValue.Add(102.5f, Actor.MakeValue(102, "FloatValueB"));
	TMap<float, FMapPrimitiveValue> FloatIn;
	FloatIn.Add(112.5f, Actor.MakeValue(112, "FloatInB"));
	TMap<float, FMapPrimitiveValue> FloatOut;
	Actor.FillFloatStructOut(FloatOut);
	TMap<float, FMapPrimitiveValue> FloatInout;
	FloatInout.Add(131.5f, Actor.MakeValue(131, "FloatInoutA"));
	Actor.MutateFloatStructInout(FloatInout);
	TMap<float, FMapPrimitiveValue> FloatReturned = Actor.ReturnFloatStruct();

	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectValue;
	ObjectValue.Add(Actor.MakeObjectKey(201), Actor.MakeValue(201, "ObjectValueA"));
	ObjectValue.Add(Actor.MakeObjectKey(202), Actor.MakeValue(202, "ObjectValueB"));
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectIn;
	ObjectIn.Add(Actor.MakeObjectKey(212), Actor.MakeValue(212, "ObjectInB"));
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectOut;
	Actor.FillObjectStructOut(ObjectOut);
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectInout;
	ObjectInout.Add(Actor.MakeObjectKey(231), Actor.MakeValue(231, "ObjectInoutA"));
	Actor.MutateObjectStructInout(ObjectInout);
	TMap<UCoverageStructMapPrimitiveKeyObject, FMapPrimitiveValue> ObjectReturned = Actor.ReturnObjectStruct();
	return Actor.CountFloatStructValue(FloatValue) == 2
		&& Actor.FloatStructValuePreserved
		&& Actor.CountFloatStructIn(FloatIn) == 1
		&& Actor.FloatStructInPreserved
		&& FloatOut.Num() == 2
		&& Actor.FloatStructInoutMutated
		&& Actor.FloatStructReturnPreserved
		&& FloatReturned.Num() == 2
		&& Actor.CountObjectStructValue(ObjectValue) == 2
		&& Actor.ObjectStructValuePreserved
		&& Actor.CountObjectStructIn(ObjectIn) == 1
		&& Actor.ObjectStructInPreserved
		&& ObjectOut.Num() == 2
		&& Actor.ObjectStructInoutSawOriginal
		&& Actor.ObjectStructReturnPreserved
		&& ObjectReturned.Num() == 2;
}

int Observe_FloatObjectStruct_ZeroFloatBoundary(ACoverageStructMapPrimitiveMatrixActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapPrimitiveKeyValueParameterAndReturnMatrix_03 setup: required Actor is null");
	}
	TMap<float, FMapPrimitiveValue> Items;
	Items.Add(0.0f, Actor.MakeValue(0, ""));
	return Actor.CountFloatStructValue(Items);
}
