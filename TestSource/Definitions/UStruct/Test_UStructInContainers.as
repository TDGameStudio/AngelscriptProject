// Theme: Definitions.UStruct. WorldStory: TArray/TMap of FItemStruct with opEquals/opCmp.
// C++: AngelscriptCoverageUStructTests.cpp::UStructInContainers spawn + BeginPlay.
// Oracle: three items Sword/Shield/Potion in array and both maps. Extra: empty containers
// before BeginPlay. FixtureIsolated.

USTRUCT()
struct FItemStruct
{
	UPROPERTY()
	int ItemID = 0;

	UPROPERTY()
	FString ItemName;

	UPROPERTY()
	float Weight = 0.0f;

	bool opEquals(const FItemStruct& Other) const
	{
		return ItemID == Other.ItemID;
	}

	int opCmp(const FItemStruct& Other) const
	{
		if (ItemID < Other.ItemID) return -1;
		if (ItemID > Other.ItemID) return 1;
		return 0;
	}
}

UCLASS()
class ACoverageStructContainerActor : AActor
{
	UPROPERTY()
	TArray<FItemStruct> ItemArray;

	UPROPERTY()
	TMap<int, FItemStruct> IDToItemMap;

	UPROPERTY()
	TMap<FString, FItemStruct> NameToItemMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Populate TArray<FStruct>
		FItemStruct Item1;
		Item1.ItemID = 1;
		Item1.ItemName = "Sword";
		Item1.Weight = 5.0f;
		ItemArray.Add(Item1);

		FItemStruct Item2;
		Item2.ItemID = 2;
		Item2.ItemName = "Shield";
		Item2.Weight = 10.0f;
		ItemArray.Add(Item2);

		FItemStruct Item3;
		Item3.ItemID = 3;
		Item3.ItemName = "Potion";
		Item3.Weight = 0.5f;
		ItemArray.Add(Item3);

		// Populate TMap<int, FStruct>
		IDToItemMap.Add(1, Item1);
		IDToItemMap.Add(2, Item2);
		IDToItemMap.Add(3, Item3);

		// Populate TMap<FString, FStruct>
		NameToItemMap.Add("Sword", Item1);
		NameToItemMap.Add("Shield", Item2);
		NameToItemMap.Add("Potion", Item3);
	}
}

bool Observe_InContainers_DefaultEmpty(ACoverageStructContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructInContainers setup: required Actor is null");
	}
	return Actor.ItemArray.Num() == 0 && Actor.IDToItemMap.Num() == 0 && Actor.NameToItemMap.Num() == 0;
}

bool Observe_InContainers_NominalBeginPlay(ACoverageStructContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructInContainers setup: required Actor is null");
	}
	Actor.BeginPlay();
	FItemStruct Found;
	return Actor.ItemArray.Num() == 3
		&& Actor.ItemArray[0].ItemName == "Sword"
		&& Actor.ItemArray[1].ItemName == "Shield"
		&& Actor.ItemArray[2].ItemName == "Potion"
		&& Actor.IDToItemMap.Num() == 3
		&& Actor.IDToItemMap.Find(2, Found) && Found.ItemName == "Shield"
		&& Actor.NameToItemMap.Find("Potion", Found) && Found.ItemID == 3;
}

bool Observe_InContainers_OpCmpBoundary()
{
	FItemStruct Low;
	Low.ItemID = 0;
	FItemStruct High;
	High.ItemID = 1;
	return (Low < High) && !(High < Low) && (Low != High);
}
