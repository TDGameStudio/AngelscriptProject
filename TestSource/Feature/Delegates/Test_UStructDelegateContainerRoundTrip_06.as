// Theme: Feature.Delegates. WorldStory block 6: BeginPlay binds and executes array/map/key-map.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 6144-6237.
// Isolation=none: wrap BeginPlay with FDelegateContainerStruct, delegate types, MakeItem,
// handlers, and UPROPERTY names the fragment writes. Oracle: ArrayValueResult 2,
// ArrayInResult 12, bKeyMapOutPreserved / bKeyMapReturnPreserved.
// Extra: empty array Num 0; zero-ID item. FixtureIsolated. Keep BeginPlay.

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

delegate int FStructArrayValueSignal(TArray<FDelegateContainerStruct> Items);
delegate int FStructArrayInSignal(const TArray<FDelegateContainerStruct>&in Items);
delegate void FStructArrayOutSignal(TArray<FDelegateContainerStruct>&out Items);
delegate int FStructArrayInoutSignal(TArray<FDelegateContainerStruct>&inout Items);
delegate TArray<FDelegateContainerStruct> FStructArrayReturnSignal();
delegate int FStructMapValueSignal(TMap<int, FDelegateContainerStruct> Items);
delegate int FStructMapInSignal(const TMap<int, FDelegateContainerStruct>&in Items);
delegate void FStructMapOutSignal(TMap<int, FDelegateContainerStruct>&out Items);
delegate int FStructMapInoutSignal(TMap<int, FDelegateContainerStruct>&inout Items);
delegate TMap<int, FDelegateContainerStruct> FStructMapReturnSignal();
delegate int FStructKeyMapValueSignal(TMap<FDelegateContainerStruct, int> Items);
delegate int FStructKeyMapInSignal(const TMap<FDelegateContainerStruct, int>&in Items);
delegate void FStructKeyMapOutSignal(TMap<FDelegateContainerStruct, int>&out Items);
delegate int FStructKeyMapInoutSignal(TMap<FDelegateContainerStruct, int>&inout Items);
delegate TMap<FDelegateContainerStruct, int> FStructKeyMapReturnSignal();
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
	FStructArrayValueSignal ArrayValueSignal;
	UPROPERTY()
	FStructArrayInSignal ArrayInSignal;
	UPROPERTY()
	FStructArrayOutSignal ArrayOutSignal;
	UPROPERTY()
	FStructArrayInoutSignal ArrayInoutSignal;
	UPROPERTY()
	FStructArrayReturnSignal ArrayReturnSignal;
	UPROPERTY()
	FStructMapValueSignal MapValueSignal;
	UPROPERTY()
	FStructMapInSignal MapInSignal;
	UPROPERTY()
	FStructMapOutSignal MapOutSignal;
	UPROPERTY()
	FStructMapInoutSignal MapInoutSignal;
	UPROPERTY()
	FStructMapReturnSignal MapReturnSignal;
	UPROPERTY()
	FStructKeyMapValueSignal KeyMapValueSignal;
	UPROPERTY()
	FStructKeyMapInSignal KeyMapInSignal;
	UPROPERTY()
	FStructKeyMapOutSignal KeyMapOutSignal;
	UPROPERTY()
	FStructKeyMapInoutSignal KeyMapInoutSignal;
	UPROPERTY()
	FStructKeyMapReturnSignal KeyMapReturnSignal;
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
	int ArrayValueResult = 0;
	UPROPERTY()
	int ArrayInResult = 0;
	UPROPERTY()
	int ArrayInoutResult = 0;
	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayOutResult;
	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayInoutResultItems;
	UPROPERTY()
	TArray<FDelegateContainerStruct> ArrayReturnResult;
	UPROPERTY()
	int MapValueResult = 0;
	UPROPERTY()
	int MapInResult = 0;
	UPROPERTY()
	int MapInoutResult = 0;
	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapOutResult;
	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapInoutResultItems;
	UPROPERTY()
	TMap<int, FDelegateContainerStruct> MapReturnResult;
	UPROPERTY()
	int KeyMapValueResult = 0;
	UPROPERTY()
	int KeyMapInResult = 0;
	UPROPERTY()
	int KeyMapInoutResult = 0;
	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapOutResult;
	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapInoutResultItems;
	UPROPERTY()
	TMap<FDelegateContainerStruct, int> KeyMapReturnResult;
	UPROPERTY()
	bool bKeyMapOutPreserved = false;
	UPROPERTY()
	bool bKeyMapReturnPreserved = false;
	UPROPERTY()
	bool bArrayValuePreserved = false;
	UPROPERTY()
	bool bArrayInPreserved = false;
	UPROPERTY()
	bool bMapValuePreserved = false;
	UPROPERTY()
	bool bMapInPreserved = false;
	UPROPERTY()
	bool bKeyMapValuePreserved = false;
	UPROPERTY()
	bool bKeyMapInPreserved = false;
	UPROPERTY()
	bool bKeyMapInoutPreserved = false;
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
	int HandleArrayValue(TArray<FDelegateContainerStruct> Items)
	{
		bArrayValuePreserved = Items.Num() == 2 && Items[1].ID == 11 && Items[1].Tag == n"ArrayValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleArrayIn(const TArray<FDelegateContainerStruct>&in Items)
	{
		bArrayInPreserved = Items.Num() == 2 && Items[0].ID == 12 && Items[0].Tag == n"ArrayInA";
		return Items.Num() + 10;
	}

	UFUNCTION()
	void HandleArrayOut(TArray<FDelegateContainerStruct>&out Items)
	{
		Items.Add(MakeItem(20, n"ArrayOutA"));
		Items.Add(MakeItem(21, n"ArrayOutB"));
	}

	UFUNCTION()
	int HandleArrayInout(TArray<FDelegateContainerStruct>&inout Items)
	{
		FDelegateContainerStruct First = Items[0];
		First.ID += 100;
		First.Tag = n"ArrayInoutMutated";
		Items[0] = First;
		Items.Add(MakeItem(22, n"ArrayInoutAdded"));
		return Items.Num() + Items[0].ID;
	}

	UFUNCTION()
	TArray<FDelegateContainerStruct> HandleArrayReturn()
	{
		TArray<FDelegateContainerStruct> Items;
		Items.Add(MakeItem(30, n"ArrayReturnA"));
		Items.Add(MakeItem(31, n"ArrayReturnB"));
		return Items;
	}

	UFUNCTION()
	int HandleMapValue(TMap<int, FDelegateContainerStruct> Items)
	{
		FDelegateContainerStruct Found;
		bMapValuePreserved = Items.Find(11, Found) && Found.ID == 11 && Found.Tag == n"MapValueB";
		return Items.Num();
	}

	UFUNCTION()
	int HandleMapIn(const TMap<int, FDelegateContainerStruct>&in Items)
	{
		FDelegateContainerStruct Found;
		bMapInPreserved = Items.Find(12, Found) && Found.ID == 12 && Found.Tag == n"MapInA";
		return Items.Num() + 20;
	}

	UFUNCTION()
	void HandleMapOut(TMap<int, FDelegateContainerStruct>&out Items)
	{
		Items.Add(20, MakeItem(20, n"MapOutA"));
		Items.Add(21, MakeItem(21, n"MapOutB"));
	}

	UFUNCTION()
	int HandleMapInout(TMap<int, FDelegateContainerStruct>&inout Items)
	{
		Items[10] = MakeItem(110, n"MapInoutMutated");
		Items.Add(22, MakeItem(22, n"MapInoutAdded"));
		return Items.Num() + Items[10].ID;
	}

	UFUNCTION()
	TMap<int, FDelegateContainerStruct> HandleMapReturn()
	{
		TMap<int, FDelegateContainerStruct> Items;
		Items.Add(30, MakeItem(30, n"MapReturnA"));
		Items.Add(31, MakeItem(31, n"MapReturnB"));
		return Items;
	}

	UFUNCTION()
	int HandleKeyMapValue(TMap<FDelegateContainerStruct, int> Items)
	{
		int Found = 0;
		bKeyMapValuePreserved = Items.Find(MakeItem(41, n"KeyMapValueB"), Found) && Found == 141;
		return Items.Num();
	}

	UFUNCTION()
	int HandleKeyMapIn(const TMap<FDelegateContainerStruct, int>&in Items)
	{
		int Found = 0;
		bKeyMapInPreserved = Items.Find(MakeItem(42, n"KeyMapInA"), Found) && Found == 142;
		return Items.Num() + 40;
	}

	UFUNCTION()
	void HandleKeyMapOut(TMap<FDelegateContainerStruct, int>&out Items)
	{
		Items.Add(MakeItem(50, n"KeyMapOutA"), 150);
		Items.Add(MakeItem(51, n"KeyMapOutB"), 151);
	}

	UFUNCTION()
	int HandleKeyMapInout(TMap<FDelegateContainerStruct, int>&inout Items)
	{
		FDelegateContainerStruct Existing = MakeItem(52, n"KeyMapInoutA");
		Items.Remove(Existing);
		Items.Add(Existing, 252);
		Items.Add(MakeItem(53, n"KeyMapInoutB"), 153);
		int Found = 0;
		bKeyMapInoutPreserved = Items.Find(Existing, Found) && Found == 252;
		return Items.Num() + Found;
	}

	UFUNCTION()
	TMap<FDelegateContainerStruct, int> HandleKeyMapReturn()
	{
		TMap<FDelegateContainerStruct, int> Items;
		Items.Add(MakeItem(54, n"KeyMapReturnA"), 154);
		Items.Add(MakeItem(55, n"KeyMapReturnB"), 155);
		return Items;
	}

	UFUNCTION()
	int HandleStructMapValue(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	int HandleStructMapIn(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	void HandleStructMapOut(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items)
	{
	}

	UFUNCTION()
	int HandleStructMapInout(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	TMap<FDelegateContainerStruct, FDelegateContainerStruct> HandleStructMapReturn()
	{
		TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items;
		return Items;
	}

	UFUNCTION()
	int HandleSetValue(TSet<FDelegateContainerStruct> Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	int HandleSetIn(const TSet<FDelegateContainerStruct>&in Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	void HandleSetOut(TSet<FDelegateContainerStruct>&out Items)
	{
	}

	UFUNCTION()
	int HandleSetInout(TSet<FDelegateContainerStruct>&inout Items)
	{
		return Items.Num();
	}

	UFUNCTION()
	TSet<FDelegateContainerStruct> HandleSetReturn()
	{
		TSet<FDelegateContainerStruct> Items;
		return Items;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ArrayValueSignal.BindUFunction(this, n"HandleArrayValue");
		ArrayInSignal.BindUFunction(this, n"HandleArrayIn");
		ArrayOutSignal.BindUFunction(this, n"HandleArrayOut");
		ArrayInoutSignal.BindUFunction(this, n"HandleArrayInout");
		ArrayReturnSignal.BindUFunction(this, n"HandleArrayReturn");

		MapValueSignal.BindUFunction(this, n"HandleMapValue");
		MapInSignal.BindUFunction(this, n"HandleMapIn");
		MapOutSignal.BindUFunction(this, n"HandleMapOut");
		MapInoutSignal.BindUFunction(this, n"HandleMapInout");
		MapReturnSignal.BindUFunction(this, n"HandleMapReturn");

		KeyMapValueSignal.BindUFunction(this, n"HandleKeyMapValue");
		KeyMapInSignal.BindUFunction(this, n"HandleKeyMapIn");
		KeyMapOutSignal.BindUFunction(this, n"HandleKeyMapOut");
		KeyMapInoutSignal.BindUFunction(this, n"HandleKeyMapInout");
		KeyMapReturnSignal.BindUFunction(this, n"HandleKeyMapReturn");

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

		TArray<FDelegateContainerStruct> ArrayValueItems;
		ArrayValueItems.Add(MakeItem(10, n"ArrayValueA"));
		ArrayValueItems.Add(MakeItem(11, n"ArrayValueB"));
		ArrayValueResult = ArrayValueSignal.Execute(ArrayValueItems);

		TArray<FDelegateContainerStruct> ArrayInItems;
		ArrayInItems.Add(MakeItem(12, n"ArrayInA"));
		ArrayInItems.Add(MakeItem(13, n"ArrayInB"));
		ArrayInResult = ArrayInSignal.Execute(ArrayInItems);

		ArrayOutSignal.Execute(ArrayOutResult);

		ArrayInoutResultItems.Add(MakeItem(10, n"ArrayInoutA"));
		ArrayInoutResult = ArrayInoutSignal.Execute(ArrayInoutResultItems);

		ArrayReturnResult = ArrayReturnSignal.Execute();

		TMap<int, FDelegateContainerStruct> MapValueItems;
		MapValueItems.Add(10, MakeItem(10, n"MapValueA"));
		MapValueItems.Add(11, MakeItem(11, n"MapValueB"));
		MapValueResult = MapValueSignal.Execute(MapValueItems);

		TMap<int, FDelegateContainerStruct> MapInItems;
		MapInItems.Add(12, MakeItem(12, n"MapInA"));
		MapInItems.Add(13, MakeItem(13, n"MapInB"));
		MapInResult = MapInSignal.Execute(MapInItems);

		MapOutSignal.Execute(MapOutResult);

		MapInoutResultItems.Add(10, MakeItem(10, n"MapInoutA"));
		MapInoutResult = MapInoutSignal.Execute(MapInoutResultItems);

		MapReturnResult = MapReturnSignal.Execute();

		TMap<FDelegateContainerStruct, int> KeyMapValueItems;
		KeyMapValueItems.Add(MakeItem(40, n"KeyMapValueA"), 140);
		KeyMapValueItems.Add(MakeItem(41, n"KeyMapValueB"), 141);
		KeyMapValueResult = KeyMapValueSignal.Execute(KeyMapValueItems);

		TMap<FDelegateContainerStruct, int> KeyMapInItems;
		KeyMapInItems.Add(MakeItem(42, n"KeyMapInA"), 142);
		KeyMapInItems.Add(MakeItem(43, n"KeyMapInB"), 143);
		KeyMapInResult = KeyMapInSignal.Execute(KeyMapInItems);

		KeyMapOutSignal.Execute(KeyMapOutResult);
		int KeyMapOutFound = 0;
		bKeyMapOutPreserved =
			KeyMapOutResult.Find(MakeItem(51, n"KeyMapOutB"), KeyMapOutFound)
			&& KeyMapOutFound == 151;

		KeyMapInoutResultItems.Add(MakeItem(52, n"KeyMapInoutA"), 152);
		KeyMapInoutResult = KeyMapInoutSignal.Execute(KeyMapInoutResultItems);

		KeyMapReturnResult = KeyMapReturnSignal.Execute();
		int KeyMapReturnFound = 0;
		bKeyMapReturnPreserved =
			KeyMapReturnResult.Find(MakeItem(55, n"KeyMapReturnB"), KeyMapReturnFound)
			&& KeyMapReturnFound == 155;
	}
}

int Observe_ArrayValueResult_DefaultZero(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_06 setup: required Actor is null");
	}
	return Actor.ArrayValueResult;
}

int Observe_EmptyArray_DefaultNum()
{
	TArray<FDelegateContainerStruct> Items;
	return Items.Num();
}

bool Observe_Item_CopyIndependence()
{
	FDelegateContainerStruct Original;
	Original.ID = 11;
	Original.Tag = n"ArrayValueB";
	FDelegateContainerStruct Copy = Original;
	Copy.ID = 0;
	return Original.ID == 11 && Copy.ID == 0;
}
