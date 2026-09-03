/**
 * A hashable USTRUCT plus array and int-to-struct map delegate types. Defaults
 * are ID 0, Hash of a zero-ID empty Tag, empty TArray Num 0, and copy
 * independence of ID and Tag.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UStructDelegateArrayAndMapTypes
 * @Harness Function
 * @Tag Feature.Delegates.UStructDelegateArrayAndMapTypes
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. Positive block 1: hashable USTRUCT plus array/map delegate types.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateContainerRoundTrip lines 5643-5675.
 * @Provenance Isolation=none: this file is a complete program. Oracle: default ID 0; Hash(0)+empty Tag.
 * @Provenance Extra: empty TArray/TMap Num 0; copy independence of ID/Tag. DefaultSafe.
 */

USTRUCT(BlueprintType)
struct FDelegateContainerStruct
{
	UPROPERTY()
	int ID = 0;

	UPROPERTY()
	FName Tag;

	/**
	 * Equality of ID and Tag.
	 *
	 * @Covers Delegates.UStruct
	 * @Param Other the other item
	 * @Inputs Other.ID and Other.Tag
	 * @Return true when both ID and Tag match
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
	 * A stable mix of ID and Tag.
	 *
	 * @Covers Delegates.UStruct
	 * @Inputs ID and Tag
	 * @Return uint32(ID * 977) + Tag.GetHash()
	 */
	uint32 Hash() const
	{
		return uint32(ID * 977) + Tag.GetHash();
	}
}

/**
 * A unicast that takes a struct array by value.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructArrayValueSignal(TArray<FDelegateContainerStruct> Items);

/**
 * A unicast that takes a struct array by const in-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructArrayInSignal(const TArray<FDelegateContainerStruct>&in Items);

/**
 * A unicast that fills a struct array by out-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return nothing; Items is written
 */
delegate void FStructArrayOutSignal(TArray<FDelegateContainerStruct>&out Items);

/**
 * A unicast that mutates a struct array by inout-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructArrayInoutSignal(TArray<FDelegateContainerStruct>&inout Items);

/**
 * A unicast that returns a struct array.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return a TArray of FDelegateContainerStruct
 */
delegate TArray<FDelegateContainerStruct> FStructArrayReturnSignal();

/**
 * A unicast that takes a map of int to struct by value.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructMapValueSignal(TMap<int, FDelegateContainerStruct> Items);

/**
 * A unicast that takes a map of int to struct by const in-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructMapInSignal(const TMap<int, FDelegateContainerStruct>&in Items);

/**
 * A unicast that fills a map of int to struct by out-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return nothing; Items is written
 */
delegate void FStructMapOutSignal(TMap<int, FDelegateContainerStruct>&out Items);

/**
 * A unicast that mutates a map of int to struct by inout-reference.
 *
 * @Covers Delegates.Declaration
 * @Inputs Items
 * @Return an int from the bound handler
 */
delegate int FStructMapInoutSignal(TMap<int, FDelegateContainerStruct>&inout Items);

/**
 * A unicast that returns a map of int to struct.
 *
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return a TMap of int to FDelegateContainerStruct
 */
delegate TMap<int, FDelegateContainerStruct> FStructMapReturnSignal();

namespace DelegatesTest
{
	/**
	 * Observe that a default item has ID 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs a default FDelegateContainerStruct
	 * @Return 0
	 * @Boundary default ID
	 */
	UFUNCTION()
	int ItemDefaultZero()
	{
		FDelegateContainerStruct Item;
		return Item.ID;
	}

	/**
	 * Observe the hash of a default item.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs a default FDelegateContainerStruct
	 * @Return Hash() of ID 0 and an empty Tag
	 * @Boundary default hash
	 */
	UFUNCTION()
	uint32 ItemDefaultHash()
	{
		FDelegateContainerStruct Item;
		return Item.Hash();
	}

	/**
	 * Observe that an empty struct array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs an empty TArray
	 * @Return 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	int EmptyArrayDefaultNum()
	{
		TArray<FDelegateContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe that copying an item and clearing the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs Original ID 11 Tag ArrayValueB; Copy cleared
	 * @Return true when Original keeps 11 / ArrayValueB and Copy.ID is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ItemCopyIndependence()
	{
		FDelegateContainerStruct Original;
		Original.ID = 11;
		Original.Tag = n"ArrayValueB";
		FDelegateContainerStruct Copy = Original;
		Copy.ID = 0;
		Copy.Tag = n"";
		if (Original.ID != 11)
		{
			return false;
		}
		if (Original.Tag != n"ArrayValueB")
		{
			return false;
		}
		return Copy.ID == 0;
	}
}
