// Theme: Feature.Delegates. Positive block 7: BeginPlay struct-map and set executes.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 6238-6285.
// Isolation=none: wrap the trailing BeginPlay statements with FDelegateContainerStruct,
// delegate types, MakeItem, handlers, and UPROPERTY names the fragment writes.
// Oracle: StructMapValueResult 2, bStructMapOutPreserved / bStructMapReturnPreserved,
// SetValueResult 2. Extra: empty TMap/TSet Num 0; zero-ID miss. DefaultSafe.

USTRUCT(BlueprintType)
struct FDelegateContainerStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	bool opEquals(const FDelegateContainerStruct& Other) const
	{
		return ID == Other.ID && Tag == Other.Tag;
	}

	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

delegate int FStructStructMapValueSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items);
delegate int FStructStructMapInSignal(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items);
delegate void FStructStructMapOutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items);
delegate int FStructStructMapInoutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items);
delegate TMap<FDelegateContainerStruct, FDelegateContainerStruct> FStructStructMapReturnSignal();
delegate int FStructSetValueSignal(TSet<FDelegateContainerStruct> Items);
delegate int FStructSetInSignal(const TSet<FDelegateContainerStruct>&in Items);
delegate void FStructSetOutSignal(TSet<FDelegateContainerStruct>&out Items);
delegate int FStructSetInoutSignal(TSet<FDelegateContainerStruct>&inout Items);
delegate TSet<FDelegateContainerStruct> FStructSetReturnSignal();

UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	FStructStructMapValueSignal StructMapValueSignal;
	UPROPERTY()
	FStructStructMapInSignal StructMapInSignal;
	UPROPERTY()
	FStructStructMapOutSignal StructMapOutSignal;
	UPROPERTY()
	FStructStructMapInoutSignal StructMapInoutSignal;
	UPROPERTY()
	FStructStructMapReturnSignal StructMapReturnSignal;
	UPROPERTY()
	FStructSetValueSignal SetValueSignal;
	UPROPERTY()
	FStructSetInSignal SetInSignal;
	UPROPERTY()
	FStructSetOutSignal SetOutSignal;
	UPROPERTY()
	FStructSetInoutSignal SetInoutSignal;
	UPROPERTY()
	FStructSetReturnSignal SetReturnSignal;

	UPROPERTY()
	int StructMapValueResult = 0;
	UPROPERTY()
	int StructMapInResult = 0;
	UPROPERTY()
	int StructMapInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapOutResult;
	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapInoutResultItems;
	UPROPERTY()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapReturnResult;
	UPROPERTY()
	int SetValueResult = 0;
	UPROPERTY()
	int SetInResult = 0;
	UPROPERTY()
	int SetInoutResult = 0;
	UPROPERTY()
	TSet<FDelegateContainerStruct> SetOutResult;
	UPROPERTY()
	TSet<FDelegateContainerStruct> SetInoutResultItems;
	UPROPERTY()
	TSet<FDelegateContainerStruct> SetReturnResult;
	UPROPERTY()
	bool bStructMapOutPreserved = false;
	UPROPERTY()
	bool bStructMapReturnPreserved = false;
	UPROPERTY()
	bool bStructMapValuePreserved = false;
	UPROPERTY()
	bool bStructMapInPreserved = false;
	UPROPERTY()
	bool bStructMapInoutPreserved = false;
	UPROPERTY()
	bool bSetValuePreserved = false;
	UPROPERTY()
	bool bSetInPreserved = false;

	FDelegateContainerStruct MakeItem(int ID, FName Tag)
	{
		FDelegateContainerStruct Item;
		Item.ID = ID;
		Item.Tag = Tag;
		return Item;
	}

	UFUNCTION()
	int HandleStructMapValue(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bStructMapValuePreserved =
			Items.Find(MakeItem(61, n"StructMapValueKeyB"), Found)
			&& Found.ID == 161
			&& Found.Tag == n"StructMapValueValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructMapIn(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bStructMapInPreserved =
			Items.Find(MakeItem(62, n"StructMapInKeyA"), Found)
			&& Found.ID == 162
			&& Found.Tag == n"StructMapInValueA";
		return Items.Num() + 60;
	}

	UFUNCTION()
	void HandleStructMapOut(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(70, n"StructMapOutKeyA"), MakeItem(170, n"StructMapOutValueA"));
		Items.Add(MakeItem(71, n"StructMapOutKeyB"), MakeItem(171, n"StructMapOutValueB"));
	}

	UFUNCTION()
	int HandleStructMapInout(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(72, n"StructMapInoutKeyA");
		Items.Remove(Existing);
		Items.Add(Existing, MakeItem(272, n"StructMapInoutMutated"));
		Items.Add(MakeItem(73, n"StructMapInoutKeyB"), MakeItem(173, n"StructMapInoutAdded"));
		FDelegateContainerStruct Found;
		bStructMapInoutPreserved =
			Items.Find(Existing, Found)
			&& Found.ID == 272
			&& Found.Tag == n"StructMapInoutMutated";
		return Items.Num() + Found.ID;
	}

	UFUNCTION()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> HandleStructMapReturn()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		Items.Add(MakeItem(74, n"StructMapReturnKeyA"), MakeItem(174, n"StructMapReturnValueA"));
		Items.Add(MakeItem(75, n"StructMapReturnKeyB"), MakeItem(175, n"StructMapReturnValueB"));
		return Items;
	}

	UFUNCTION()
	int HandleSetValue(TSet<FDelegateContainerStruct> Items)
	{
		bSetValuePreserved = Items.Contains(MakeItem(11, n"SetValueB"));
		return Items.Num();
	}

	UFUNCTION()
	int HandleSetIn(const TSet<FDelegateContainerStruct>&in Items)
	{
		bSetInPreserved = Items.Contains(MakeItem(12, n"SetInA"));
		return Items.Num() + 30;
	}

	UFUNCTION()
	void HandleSetOut(TSet<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"SetOutA"));
		Items.Add(MakeItem(21, n"SetOutB"));
	}

	UFUNCTION()
	int HandleSetInout(TSet<FDelegateContainerStruct>&inout Items)
	{
		Items.Remove(MakeItem(10, n"SetInoutA"));
		Items.Add(MakeItem(22, n"SetInoutAdded"));
		return Items.Num() + 40;
	}

	UFUNCTION()
	TSet<FDelegateContainerStruct> HandleSetReturn()
	{
		TSet<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"SetReturnA"));
		Items.Add(MakeItem(31, n"SetReturnB"));
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StructMapValueSignal.BindUFunction(this, n"HandleStructMapValue");
		StructMapInSignal.BindUFunction(this, n"HandleStructMapIn");
		StructMapOutSignal.BindUFunction(this, n"HandleStructMapOut");
		StructMapInoutSignal.BindUFunction(this, n"HandleStructMapInout");
		StructMapReturnSignal.BindUFunction(this, n"HandleStructMapReturn");
		SetValueSignal.BindUFunction(this, n"HandleSetValue");
		SetInSignal.BindUFunction(this, n"HandleSetIn");
		SetOutSignal.BindUFunction(this, n"HandleSetOut");
		SetInoutSignal.BindUFunction(this, n"HandleSetInout");
		SetReturnSignal.BindUFunction(this, n"HandleSetReturn");

		TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapValueItems;
		StructMapValueItems.Add(MakeItem(60, n"StructMapValueKeyA"), MakeItem(160, n"StructMapValueValueA"));
		StructMapValueItems.Add(MakeItem(61, n"StructMapValueKeyB"), MakeItem(161, n"StructMapValueValueB"));
		StructMapValueResult = StructMapValueSignal.Execute(StructMapValueItems);

		TMap<FDelegateContainerStruct, FDelegateContainerStruct> StructMapInItems;
		StructMapInItems.Add(MakeItem(62, n"StructMapInKeyA"), MakeItem(162, n"StructMapInValueA"));
		StructMapInItems.Add(MakeItem(63, n"StructMapInKeyB"), MakeItem(163, n"StructMapInValueB"));
		StructMapInResult = StructMapInSignal.Execute(StructMapInItems);

		StructMapOutSignal.Execute(StructMapOutResult);
		FDelegateContainerStruct StructMapOutFound;
		bStructMapOutPreserved =
			StructMapOutResult.Find(MakeItem(71, n"StructMapOutKeyB"), StructMapOutFound)
			&& StructMapOutFound.ID == 171
			&& StructMapOutFound.Tag == n"StructMapOutValueB";

		StructMapInoutResultItems.Add(MakeItem(72, n"StructMapInoutKeyA"), MakeItem(172, n"StructMapInoutOriginal"));
		StructMapInoutResult = StructMapInoutSignal.Execute(StructMapInoutResultItems);

		StructMapReturnResult = StructMapReturnSignal.Execute();
		FDelegateContainerStruct StructMapReturnFound;
		bStructMapReturnPreserved =
			StructMapReturnResult.Find(MakeItem(75, n"StructMapReturnKeyB"), StructMapReturnFound)
			&& StructMapReturnFound.ID == 175
			&& StructMapReturnFound.Tag == n"StructMapReturnValueB";

		TSet<FDelegateContainerStruct> SetValueItems;
		SetValueItems.Add(MakeItem(10, n"SetValueA"));
		SetValueItems.Add(MakeItem(11, n"SetValueB"));
		SetValueResult = SetValueSignal.Execute(SetValueItems);

		TSet<FDelegateContainerStruct> SetInItems;
		SetInItems.Add(MakeItem(12, n"SetInA"));
		SetInItems.Add(MakeItem(13, n"SetInB"));
		SetInResult = SetInSignal.Execute(SetInItems);

		SetOutSignal.Execute(SetOutResult);

		SetInoutResultItems.Add(MakeItem(10, n"SetInoutA"));
		SetInoutResult = SetInoutSignal.Execute(SetInoutResultItems);

		SetReturnResult = SetReturnSignal.Execute();
	}
}

int Observe_StructMapValueResult_DefaultZero(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_07 setup: required Actor is null");
	}
	return Actor.StructMapValueResult;
}

int Observe_EmptySet_DefaultNum()
{
	TSet<FDelegateContainerStruct> Items;
	return Items.Num();
}

bool Observe_Item_CopyIndependence()
{
	FDelegateContainerStruct Original;
	Original.ID = 161;
	Original.Tag = n"StructMapValueValueB";
	FDelegateContainerStruct Copy = Original;
	Copy.ID = 0;
	return Original.ID == 161 && Copy.ID == 0;
}
