// Theme: Feature.Delegates. WorldStory block 2: key-map/set delegates and actor storage.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5676-5863.
// Isolation=none: wrap with FDelegateContainerStruct and array/map delegate types the
// UPROPERTY members use. Oracle: default ArrayValueResult 0 / empty containers.
// Extra: empty TSet Num 0; default ID 0. FixtureIsolated.

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
}

int Observe_ArrayValueResult_DefaultZero(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_02 setup: required Actor is null");
	}
	return Actor.ArrayValueResult;
}

int Observe_EmptySet_DefaultNum()
{
	TSet<FDelegateContainerStruct> Items;
	return Items.Num();
}

int Observe_ArrayOutResult_DefaultNum(ACoverageStructDelegateContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateContainerRoundTrip_02 setup: required Actor is null");
	}
	return Actor.ArrayOutResult.Num();
}
