/**
 * @version v1
 * @summary TArray and TMap of FItemStruct with opEquals and opCmp. C++ reads three items Sword/Shield/Potion after BeginPlay. Keep ItemArray, IDToItemMap, and NameToItemMap.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray and TMap of FItemStruct with opEquals and opCmp. C++ reads three items Sword/Shield/Potion after BeginPlay. Keep ItemArray, IDToItemMap, and NameToItemMap.
 * @topic Baseline
 */
USTRUCT()
struct FItemStruct
{
	UPROPERTY()
	int ItemID = 0;

	UPROPERTY()
	FString ItemName;

	UPROPERTY()
	float Weight = 0.0f;

	/**
	 * Compare two items by ItemID.
	 *
	 * @Covers UStruct.UStructInContainers
	 * @Inputs another FItemStruct
	 * @Return true when ItemID matches
	 * @Param Other the other item
	 */
	bool opEquals(const FItemStruct&in Other) const
	{
		return ItemID == Other.ItemID;
	}

	/**
	 * Compare two items by ItemID.
	 *
	 * @Covers UStruct.UStructInContainers
	 * @Inputs another FItemStruct
	 * @Return -1, 0, or 1
	 * @Param Other the other item
	 */
	int opCmp(const FItemStruct&in Other) const
	{
		if (ItemID < Other.ItemID)
		{
			return -1;
		}
		if (ItemID > Other.ItemID)
		{
			return 1;
		}
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

	/**
	 * WorldStory: BeginPlay fills the array and both maps with three items.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructInContainers
	 * @Inputs none
	 * @Return three items Sword/Shield/Potion in array and both maps
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
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

		IDToItemMap.Add(1, Item1);
		IDToItemMap.Add(2, Item2);
		IDToItemMap.Add(3, Item3);

		NameToItemMap.Add("Sword", Item1);
		NameToItemMap.Add("Shield", Item2);
		NameToItemMap.Add("Potion", Item3);
	}

	/**
	 * Observe empty containers before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructInContainers
	 * @Inputs an actor that has not begun play
	 * @Return true when array and both maps have Num 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool InContainersDefaultEmpty()
	{
		if (ItemArray.Num() != 0)
		{
			return false;
		}
		if (IDToItemMap.Num() != 0)
		{
			return false;
		}
		return NameToItemMap.Num() == 0;
	}

	/**
	 * Observe the three items after BeginPlay.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructInContainers
	 * @Inputs BeginPlay on this actor
	 * @Return true when Sword/Shield/Potion are in the array and both maps
	 */
	UFUNCTION()
	bool InContainersNominalBeginPlay()
	{
		BeginPlay();
		FItemStruct Found;
		if (ItemArray.Num() != 3)
		{
			return false;
		}
		if (ItemArray[0].ItemName != "Sword")
		{
			return false;
		}
		if (ItemArray[1].ItemName != "Shield")
		{
			return false;
		}
		if (ItemArray[2].ItemName != "Potion")
		{
			return false;
		}
		if (IDToItemMap.Num() != 3)
		{
			return false;
		}
		if (!IDToItemMap.Find(2, Found))
		{
			return false;
		}
		if (Found.ItemName != "Shield")
		{
			return false;
		}
		if (!NameToItemMap.Find("Potion", Found))
		{
			return false;
		}
		return Found.ItemID == 3;
	}

	/**
	 * Observe opCmp and inequality on ItemID 0 versus 1.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructInContainers
	 * @Inputs Low.ItemID 0 and High.ItemID 1
	 * @Return true when Low < High, High is not < Low, and they are unequal
	 * @Boundary ordered ids
	 */
	UFUNCTION()
	bool InContainersOpCmpBoundary()
	{
		FItemStruct Low;
		Low.ItemID = 0;
		FItemStruct High;
		High.ItemID = 1;
		if (!(Low < High))
		{
			return false;
		}
		if (High < Low)
		{
			return false;
		}
		return Low != High;
	}
}
/** @end */
