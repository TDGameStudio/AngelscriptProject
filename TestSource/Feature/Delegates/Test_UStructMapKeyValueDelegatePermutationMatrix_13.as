// Theme: Feature.Delegates. Positive block 13: BeginPlay struct-name and struct-object executes.
// C++: AngelscriptCoverageUStructTests.cpp::UStructMapKeyValueDelegatePermutationMatrix lines 8254-8321.
// Isolation=none: wrap the trailing BeginPlay with name/object signals, MakeKey/MakeObject,
// handlers. Oracle: StructNameValueResult 2; StructNameOutB preserved; StructObjectOutB Value 522;
// StructObjectInout mutated 631; StructObjectReturnB 542.
// Extra: empty maps Num 0; null object miss. DefaultSafe.

UCLASS()
class UCoverageStructDelegateMapValueObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FDelegateKeyValueMapKey
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateKeyValueMapKey& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 929) + Tag.GetHash();
	}
}

delegate int FStructNameMapValueSignal(TMap<FDelegateKeyValueMapKey, FName> Items);
delegate int FStructNameMapInSignal(const TMap<FDelegateKeyValueMapKey, FName>&in Items);
delegate void FStructNameMapOutSignal(TMap<FDelegateKeyValueMapKey, FName>&out Items);
delegate int FStructNameMapInoutSignal(TMap<FDelegateKeyValueMapKey, FName>&inout Items);
delegate TMap<FDelegateKeyValueMapKey, FName> FStructNameMapReturnSignal();
delegate int FStructObjectMapValueSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items);
delegate int FStructObjectMapInSignal(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items);
delegate void FStructObjectMapOutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items);
delegate int FStructObjectMapInoutSignal(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items);
delegate TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> FStructObjectMapReturnSignal();

UCLASS()
class ACoverageStructMapKeyValueDelegateActor : AActor
{
	UPROPERTY()
	FStructNameMapValueSignal StructNameValueSignal;
	UPROPERTY()
	FStructNameMapInSignal StructNameInSignal;
	UPROPERTY()
	FStructNameMapOutSignal StructNameOutSignal;
	UPROPERTY()
	FStructNameMapInoutSignal StructNameInoutSignal;
	UPROPERTY()
	FStructNameMapReturnSignal StructNameReturnSignal;
	UPROPERTY()
	FStructObjectMapValueSignal StructObjectValueSignal;
	UPROPERTY()
	FStructObjectMapInSignal StructObjectInSignal;
	UPROPERTY()
	FStructObjectMapOutSignal StructObjectOutSignal;
	UPROPERTY()
	FStructObjectMapInoutSignal StructObjectInoutSignal;
	UPROPERTY()
	FStructObjectMapReturnSignal StructObjectReturnSignal;

	UPROPERTY()
	int StructNameValueResult = 0;
	UPROPERTY()
	int StructNameInResult = 0;
	UPROPERTY()
	int StructNameInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameOutResult;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameInoutResultItems;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, FName> StructNameReturnResult;
	UPROPERTY()
	bool StructNameValuePreserved = false;
	UPROPERTY()
	bool StructNameInPreserved = false;
	UPROPERTY()
	bool StructNameOutPreserved = false;
	UPROPERTY()
	bool StructNameInoutPreserved = false;
	UPROPERTY()
	bool StructNameReturnPreserved = false;
	UPROPERTY()
	int StructObjectValueResult = 0;
	UPROPERTY()
	int StructObjectInResult = 0;
	UPROPERTY()
	int StructObjectInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectOutResult;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectInoutResultItems;
	UPROPERTY()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectReturnResult;
	UPROPERTY()
	bool StructObjectValuePreserved = false;
	UPROPERTY()
	bool StructObjectInPreserved = false;
	UPROPERTY()
	bool StructObjectOutPreserved = false;
	UPROPERTY()
	bool StructObjectInoutPreserved = false;
	UPROPERTY()
	bool StructObjectReturnPreserved = false;

	FDelegateKeyValueMapKey MakeKey(int ID, FName Tag)
	{
		FDelegateKeyValueMapKey Key;
		Key.ID = ID;
		Key.Tag = Tag;
		return Key;
	}

	UCoverageStructDelegateMapValueObject MakeObject(int Value)
	{
		UCoverageStructDelegateMapValueObject Object = Cast<UCoverageStructDelegateMapValueObject>(NewObject(this, UCoverageStructDelegateMapValueObject::StaticClass()));
		Object.Value = Value;
		return Object;
	}

	UFUNCTION()
	int HandleStructNameValue(TMap<FDelegateKeyValueMapKey, FName> Items)
	{
		FName Found;
		StructNameValuePreserved = Items.Find(MakeKey(401, n"StructNameValueB"), Found) && Found == n"StructNameValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructNameIn(const TMap<FDelegateKeyValueMapKey, FName>&in Items)
	{
		FName Found;
		StructNameInPreserved = Items.Find(MakeKey(411, n"StructNameInB"), Found) && Found == n"StructNameInB";
		return Items.Num() + 50;
	}

	UFUNCTION()
	void HandleStructNameOut(TMap<FDelegateKeyValueMapKey, FName>&out Items)
	{
		Items.Add(MakeKey(420, n"StructNameOutA"), n"StructNameOutA");
		Items.Add(MakeKey(421, n"StructNameOutB"), n"StructNameOutB");
	}

	UFUNCTION()
	int HandleStructNameInout(TMap<FDelegateKeyValueMapKey, FName>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(430, n"StructNameInoutA");
		FName Found;
		if (Items.Find(Existing, Found))
		{
			Items.Add(Existing, n"StructNameInoutMutated");
		}
		Items.Add(MakeKey(431, n"StructNameInoutB"), n"StructNameInoutAdded");
		StructNameInoutResultItems = Items;
		FName Mutated;
		StructNameInoutPreserved = Items.Find(Existing, Mutated) && Mutated == n"StructNameInoutMutated";
		return Items.Num() + 60;
	}

	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, FName> HandleStructNameReturn()
	{
		TMap<FDelegateKeyValueMapKey, FName> Items;
		Items.Add(MakeKey(440, n"StructNameReturnA"), n"StructNameReturnA");
		Items.Add(MakeKey(441, n"StructNameReturnB"), n"StructNameReturnB");
		return Items;
	}

	UFUNCTION()
	int HandleStructObjectValue(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectValuePreserved = Items.Find(MakeKey(501, n"StructObjectValueB"), Found) && Found != nullptr && Found.Value == 502;
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructObjectIn(const TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&in Items)
	{
		UCoverageStructDelegateMapValueObject Found = nullptr;
		StructObjectInPreserved = Items.Find(MakeKey(511, n"StructObjectInB"), Found) && Found != nullptr && Found.Value == 512;
		return Items.Num() + 70;
	}

	UFUNCTION()
	void HandleStructObjectOut(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&out Items)
	{
		Items.Add(MakeKey(520, n"StructObjectOutA"), MakeObject(521));
		Items.Add(MakeKey(521, n"StructObjectOutB"), MakeObject(522));
	}

	UFUNCTION()
	int HandleStructObjectInout(TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject>&inout Items)
	{
		FDelegateKeyValueMapKey Existing = MakeKey(530, n"StructObjectInoutA");
		UCoverageStructDelegateMapValueObject Found = nullptr;
		if (Items.Find(Existing, Found) && Found != nullptr)
		{
			Items.Add(Existing, MakeObject(Found.Value + 100));
		}
		Items.Add(MakeKey(531, n"StructObjectInoutB"), MakeObject(532));
		StructObjectInoutResultItems = Items;
		UCoverageStructDelegateMapValueObject Mutated = nullptr;
		StructObjectInoutPreserved = Items.Find(Existing, Mutated) && Mutated != nullptr && Mutated.Value == 631;
		return Items.Num() + 80;
	}

	UFUNCTION()
	TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> HandleStructObjectReturn()
	{
		TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> Items;
		Items.Add(MakeKey(540, n"StructObjectReturnA"), MakeObject(541));
		Items.Add(MakeKey(541, n"StructObjectReturnB"), MakeObject(542));
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StructNameValueSignal.BindUFunction(this, n"HandleStructNameValue");
		StructNameInSignal.BindUFunction(this, n"HandleStructNameIn");
		StructNameOutSignal.BindUFunction(this, n"HandleStructNameOut");
		StructNameInoutSignal.BindUFunction(this, n"HandleStructNameInout");
		StructNameReturnSignal.BindUFunction(this, n"HandleStructNameReturn");

		TMap<FDelegateKeyValueMapKey, FName> StructNameValueItems;
		StructNameValueItems.Add(MakeKey(400, n"StructNameValueA"), n"StructNameValueA");
		StructNameValueItems.Add(MakeKey(401, n"StructNameValueB"), n"StructNameValueB");
		StructNameValueResult = StructNameValueSignal.Execute(StructNameValueItems);

		TMap<FDelegateKeyValueMapKey, FName> StructNameInItems;
		StructNameInItems.Add(MakeKey(410, n"StructNameInA"), n"StructNameInA");
		StructNameInItems.Add(MakeKey(411, n"StructNameInB"), n"StructNameInB");
		StructNameInResult = StructNameInSignal.Execute(StructNameInItems);

		StructNameOutSignal.Execute(StructNameOutResult);
		FName StructNameOutFound;
		StructNameOutPreserved =
			StructNameOutResult.Find(MakeKey(421, n"StructNameOutB"), StructNameOutFound)
			&& StructNameOutFound == n"StructNameOutB";

		StructNameInoutResultItems.Add(MakeKey(430, n"StructNameInoutA"), n"StructNameInoutA");
		StructNameInoutResult = StructNameInoutSignal.Execute(StructNameInoutResultItems);

		StructNameReturnResult = StructNameReturnSignal.Execute();
		FName StructNameReturnFound;
		StructNameReturnPreserved =
			StructNameReturnResult.Find(MakeKey(441, n"StructNameReturnB"), StructNameReturnFound)
			&& StructNameReturnFound == n"StructNameReturnB";

		StructObjectValueSignal.BindUFunction(this, n"HandleStructObjectValue");
		StructObjectInSignal.BindUFunction(this, n"HandleStructObjectIn");
		StructObjectOutSignal.BindUFunction(this, n"HandleStructObjectOut");
		StructObjectInoutSignal.BindUFunction(this, n"HandleStructObjectInout");
		StructObjectReturnSignal.BindUFunction(this, n"HandleStructObjectReturn");

		TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectValueItems;
		StructObjectValueItems.Add(MakeKey(500, n"StructObjectValueA"), MakeObject(501));
		StructObjectValueItems.Add(MakeKey(501, n"StructObjectValueB"), MakeObject(502));
		StructObjectValueResult = StructObjectValueSignal.Execute(StructObjectValueItems);

		TMap<FDelegateKeyValueMapKey, UCoverageStructDelegateMapValueObject> StructObjectInItems;
		StructObjectInItems.Add(MakeKey(510, n"StructObjectInA"), MakeObject(511));
		StructObjectInItems.Add(MakeKey(511, n"StructObjectInB"), MakeObject(512));
		StructObjectInResult = StructObjectInSignal.Execute(StructObjectInItems);

		StructObjectOutSignal.Execute(StructObjectOutResult);
		UCoverageStructDelegateMapValueObject StructObjectOutFound = nullptr;
		StructObjectOutPreserved =
			StructObjectOutResult.Find(MakeKey(521, n"StructObjectOutB"), StructObjectOutFound)
			&& StructObjectOutFound != nullptr
			&& StructObjectOutFound.Value == 522;

		StructObjectInoutResultItems.Add(MakeKey(530, n"StructObjectInoutA"), MakeObject(531));
		StructObjectInoutResult = StructObjectInoutSignal.Execute(StructObjectInoutResultItems);

		StructObjectReturnResult = StructObjectReturnSignal.Execute();
		UCoverageStructDelegateMapValueObject StructObjectReturnFound = nullptr;
		StructObjectReturnPreserved =
			StructObjectReturnResult.Find(MakeKey(541, n"StructObjectReturnB"), StructObjectReturnFound)
			&& StructObjectReturnFound != nullptr
			&& StructObjectReturnFound.Value == 542;
	}
}

int Observe_StructNameValueResult_DefaultZero(ACoverageStructMapKeyValueDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructMapKeyValueDelegatePermutationMatrix_13 setup: required Actor is null");
	}
	return Actor.StructNameValueResult;
}

int Observe_EmptyNameMap_DefaultNum()
{
	TMap<FDelegateKeyValueMapKey, FName> Items;
	return Items.Num();
}

bool Observe_ValueObject_NullBoundary()
{
	UCoverageStructDelegateMapValueObject Object = nullptr;
	return Object == nullptr;
}
