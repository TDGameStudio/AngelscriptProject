// Theme: Definitions.UStruct. WorldStory: empty USTRUCT as TArray/TMap/TSet members.
// C++: AngelscriptCoverageUStructTests.cpp::UStructEmptyContainerShapeMatrix block 1
// lines 2076-2174;
// sha256=9c5ea146deacaf35b57eb460c10e20fc2112dc9117810d87fe6104c7935a1741.
// Oracle: EmptyArray/IntToEmpty/EmptyToInt/EmptyToEmpty/EmptySet reflect; spawn defaults Num 0
// before BeginPlay (this fragment has no BeginPlay).
// Extra: local empty containers Num 0; opEquals always true; Hash is 17.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	bool opEquals(const FEmptyContainerStruct& Other) const
	{
		return true;
	}

	uint32 Hash() const
	{
		return 17;
	}
}

UCLASS()
class ACoverageEmptyStructContainerActor : AActor
{
	UPROPERTY()
	TArray<FEmptyContainerStruct> EmptyArray;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> IntToEmpty;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> EmptyToInt;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> EmptyToEmpty;

	UPROPERTY()
	TSet<FEmptyContainerStruct> EmptySet;

	UPROPERTY()
	int ArrayValueCount = 0;

	UPROPERTY()
	int ArrayInCount = 0;

	UPROPERTY()
	TArray<FEmptyContainerStruct> ArrayInout;

	UPROPERTY()
	int MapValueCount = 0;

	UPROPERTY()
	int MapInCount = 0;

	UPROPERTY()
	TMap<int, FEmptyContainerStruct> MapInout;

	UPROPERTY()
	int StructKeyMapValueCount = 0;

	UPROPERTY()
	int StructKeyMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, int> StructKeyMapOut;

	UPROPERTY()
	int StructStructMapValueCount = 0;

	UPROPERTY()
	int StructStructMapInCount = 0;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapInout;

	UPROPERTY()
	TMap<FEmptyContainerStruct, FEmptyContainerStruct> StructStructMapOut;

	UPROPERTY()
	int SetValueCount = 0;

	UPROPERTY()
	int SetInCount = 0;

	UPROPERTY()
	TSet<FEmptyContainerStruct> SetInout;

	UPROPERTY()
	bool EmptySetDeduplicated = false;

	UPROPERTY()
	bool EmptyKeyMapOverwrote = false;

	UPROPERTY()
	bool EmptyKeyMapInFound = false;

	UPROPERTY()
	bool EmptyStructStructMapFound = false;

	UPROPERTY()
	bool EmptyStructStructMapInFound = false;
}

int Observe_EmptyArray_DefaultNum()
{
	TArray<FEmptyContainerStruct> EmptyArray;
	return EmptyArray.Num();
}

int Observe_EmptyMap_DefaultNum()
{
	TMap<int, FEmptyContainerStruct> IntToEmpty;
	return IntToEmpty.Num();
}

int Observe_EmptySet_DefaultNum()
{
	TSet<FEmptyContainerStruct> EmptySet;
	return EmptySet.Num();
}

bool Observe_EmptyStruct_EqualsAlwaysTrue()
{
	FEmptyContainerStruct Left;
	FEmptyContainerStruct Right;
	return Left.opEquals(Right);
}

uint32 Observe_EmptyStruct_Hash()
{
	FEmptyContainerStruct Item;
	return Item.Hash();
}

bool Observe_EmptySet_DedupBoundary()
{
	TSet<FEmptyContainerStruct> EmptySet;
	FEmptyContainerStruct Item;
	EmptySet.Add(Item);
	EmptySet.Add(Item);
	return EmptySet.Num() == 1 && EmptySet.Contains(Item);
}
