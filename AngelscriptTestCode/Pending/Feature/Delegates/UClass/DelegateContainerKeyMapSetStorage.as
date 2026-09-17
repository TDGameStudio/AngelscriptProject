/**
 * @version v1
 * @summary Key-map/set delegates and actor storage. Default ArrayValueResult 0 and empty containers. Empty TSet Num 0. Default ID 0.
 * @topic Feature
 */
/**
 * @version root
 * @summary Key-map/set delegates and actor storage. Default ArrayValueResult 0 and empty containers. Empty TSet Num 0. Default ID 0.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FDelegateContainerStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Compare two items by ID and Tag.
	 *
	 * @Covers Delegates.DelegateContainerKeyMapSetStorage
	 * @Inputs another FDelegateContainerStruct
	 * @Return true when ID and Tag match
	 * @Param Other the other item
	 */
	bool opEquals(const FDelegateContainerStruct&in Other) const
	{
		if (ID != Other.ID)
		{
			return false;
		}
		return Tag == Other.Tag;
	}

	/**
	 * Hash as ID * 977 plus Tag.GetHash().
	 *
	 * @Covers Delegates.DelegateContainerKeyMapSetStorage
	 * @Inputs none
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

/**
 * Array-by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayValueSignal(TArray<FDelegateContainerStruct> Items);

/**
 * Array const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayInSignal(const TArray<FDelegateContainerStruct>&in Items);

/**
 * Array &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructArrayOutSignal(TArray<FDelegateContainerStruct>&out Items);

/**
 * Array &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructArrayInoutSignal(TArray<FDelegateContainerStruct>&inout Items);

/**
 * Array-return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TArray of items
 */
delegate TArray<FDelegateContainerStruct> FStructArrayReturnSignal();

/**
 * Int-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapValueSignal(TMap<int, FDelegateContainerStruct> Items);

/**
 * Int-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapInSignal(const TMap<int, FDelegateContainerStruct>&in Items);

/**
 * Int-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructMapOutSignal(TMap<int, FDelegateContainerStruct>&out Items);

/**
 * Int-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructMapInoutSignal(TMap<int, FDelegateContainerStruct>&inout Items);

/**
 * Int-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of items
 */
delegate TMap<int, FDelegateContainerStruct> FStructMapReturnSignal();

/**
 * Struct-key map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapValueSignal(TMap<FDelegateContainerStruct, int> Items);

/**
 * Struct-key map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapInSignal(const TMap<FDelegateContainerStruct, int>&in Items);

/**
 * Struct-key map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructKeyMapOutSignal(TMap<FDelegateContainerStruct, int>&out Items);

/**
 * Struct-key map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructKeyMapInoutSignal(TMap<FDelegateContainerStruct, int>&inout Items);

/**
 * Struct-key map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of scores
 */
delegate TMap<FDelegateContainerStruct, int> FStructKeyMapReturnSignal();

/**
 * Struct-to-struct map by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapValueSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct> Items);

/**
 * Struct-to-struct map const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapInSignal(const TMap<FDelegateContainerStruct, FDelegateContainerStruct>&in Items);

/**
 * Struct-to-struct map &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructStructMapOutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&out Items);

/**
 * Struct-to-struct map &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructStructMapInoutSignal(TMap<FDelegateContainerStruct, FDelegateContainerStruct>&inout Items);

/**
 * Struct-to-struct map return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TMap of structs
 */
delegate TMap<FDelegateContainerStruct, FDelegateContainerStruct> FStructStructMapReturnSignal();

/**
 * Set by-value unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetValueSignal(TSet<FDelegateContainerStruct> Items);

/**
 * Set const-&in unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetInSignal(const TSet<FDelegateContainerStruct>&in Items);

/**
 * Set &out unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return void
 */
delegate void FStructSetOutSignal(TSet<FDelegateContainerStruct>&out Items);

/**
 * Set &inout unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs Items
 * @Return int
 */
delegate int FStructSetInoutSignal(TSet<FDelegateContainerStruct>&inout Items);

/**
 * Set return unicast.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return TSet of items
 */
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

	/**
	 * Observe the default ArrayValueResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ArrayValueResult
	 */
	UFUNCTION()
	int ArrayValueResultDefaultZero()
	{
		return ArrayValueResult;
	}

	/**
	 * Observe empty TSet Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs an empty set
	 * @Return 0
	 * @Boundary empty set
	 */
	UFUNCTION()
	int EmptySetDefaultNum()
	{
		TSet<FDelegateContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe the default ArrayOutResult Num.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ArrayOutResult
	 */
	UFUNCTION()
	int ArrayOutResultDefaultNum()
	{
		return ArrayOutResult.Num();
	}
}
/** @end */
