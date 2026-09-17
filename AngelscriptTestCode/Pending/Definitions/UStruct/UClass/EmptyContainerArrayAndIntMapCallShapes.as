/**
 * @version v1
 * @summary Empty USTRUCT TArray and TMap<int,FStruct> UFUNCTION call shapes. C++ counts, fills, mutates, and returns those containers.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Empty USTRUCT TArray and TMap<int,FStruct> UFUNCTION call shapes. C++ counts, fills, mutates, and returns those containers.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FEmptyContainerStruct
{
	/**
	 * Empty structs compare equal.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs another FEmptyContainerStruct
	 * @Return true
	 * @Param Other the other instance
	 */
	bool opEquals(const FEmptyContainerStruct&in Other) const
	{
		return true;
	}

	/**
	 * Hash empty structs as the constant 17.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs none
	 * @Return 17
	 */
	uint32 Hash() const
	{
		return 17;
	}
}

UCLASS()
class ACoverageEmptyStructContainerActor : AActor
{
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

	/**
	 * Build a default empty container struct.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs none
	 * @Return a default FEmptyContainerStruct
	 */
	FEmptyContainerStruct MakeEmpty()
	{
		FEmptyContainerStruct Item;
		return Item;
	}

	/**
	 * Count a by-value empty-struct array.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a TArray of FEmptyContainerStruct
	 * @Return Items.Num() stored in ArrayValueCount
	 * @Param Items the array
	 */
	UFUNCTION(BlueprintCallable)
	int CountArrayValue(TArray<FEmptyContainerStruct> Items)
	{
		ArrayValueCount = Items.Num();
		return ArrayValueCount;
	}

	/**
	 * Count a const-in empty-struct array.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a const &in TArray of FEmptyContainerStruct
	 * @Return Items.Num() stored in ArrayInCount
	 * @Param Items the array
	 */
	UFUNCTION(BlueprintCallable)
	int CountArrayIn(const TArray<FEmptyContainerStruct>&in Items)
	{
		ArrayInCount = Items.Num();
		return ArrayInCount;
	}

	/**
	 * Fill an out empty-struct array with two items.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs an &out TArray of FEmptyContainerStruct
	 * @Return Items with two MakeEmpty entries
	 * @Param Items the out array
	 */
	UFUNCTION(BlueprintCallable)
	void FillArrayOut(TArray<FEmptyContainerStruct>&out Items)
	{
		Items.Add(MakeEmpty());
		Items.Add(MakeEmpty());
	}

	/**
	 * Append one empty struct to an inout array.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs an &inout TArray of FEmptyContainerStruct
	 * @Return ArrayInout copied from Items after the append
	 * @Param Items the inout array
	 */
	UFUNCTION(BlueprintCallable)
	void MutateArrayInout(TArray<FEmptyContainerStruct>&inout Items)
	{
		Items.Add(MakeEmpty());
		ArrayInout = Items;
	}

	/**
	 * Return an array of two empty structs.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs none
	 * @Return a TArray with two MakeEmpty entries
	 */
	UFUNCTION(BlueprintCallable)
	TArray<FEmptyContainerStruct> ReturnArray()
	{
		TArray<FEmptyContainerStruct> Items;
		Items.Add(MakeEmpty());
		Items.Add(MakeEmpty());
		return Items;
	}

	/**
	 * Count a by-value int-to-empty map.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a TMap of int to FEmptyContainerStruct
	 * @Return Items.Num() stored in MapValueCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountMapValue(TMap<int, FEmptyContainerStruct> Items)
	{
		MapValueCount = Items.Num();
		return MapValueCount;
	}

	/**
	 * Count a const-in int-to-empty map.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a const &in TMap of int to FEmptyContainerStruct
	 * @Return Items.Num() stored in MapInCount
	 * @Param Items the map
	 */
	UFUNCTION(BlueprintCallable)
	int CountMapIn(const TMap<int, FEmptyContainerStruct>&in Items)
	{
		MapInCount = Items.Num();
		return MapInCount;
	}

	/**
	 * Fill an out int-to-empty map with two entries.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs an &out TMap of int to FEmptyContainerStruct
	 * @Return Items with keys 10 and 11
	 * @Param Items the out map
	 */
	UFUNCTION(BlueprintCallable)
	void FillMapOut(TMap<int, FEmptyContainerStruct>&out Items)
	{
		Items.Add(10, MakeEmpty());
		Items.Add(11, MakeEmpty());
	}

	/**
	 * Append one int-to-empty entry to an inout map.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs an &inout TMap of int to FEmptyContainerStruct
	 * @Return MapInout copied from Items after adding key 12
	 * @Param Items the inout map
	 */
	UFUNCTION(BlueprintCallable)
	void MutateMapInout(TMap<int, FEmptyContainerStruct>&inout Items)
	{
		Items.Add(12, MakeEmpty());
		MapInout = Items;
	}

	/**
	 * Return an int-to-empty map with two entries.
	 *
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs none
	 * @Return a TMap with keys 20 and 21
	 */
	UFUNCTION(BlueprintCallable)
	TMap<int, FEmptyContainerStruct> ReturnMap()
	{
		TMap<int, FEmptyContainerStruct> Items;
		Items.Add(20, MakeEmpty());
		Items.Add(21, MakeEmpty());
		return Items;
	}

	/**
	 * Observe that a local empty-struct array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a default TArray of FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty array
	 */
	UFUNCTION()
	int ArrayValueEmptyDefault()
	{
		TArray<FEmptyContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe two MakeEmpty adds on an array.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs two Add of a default empty struct
	 * @Return 2
	 * @Boundary two items
	 */
	UFUNCTION()
	int ArrayValueTwoItems()
	{
		TArray<FEmptyContainerStruct> Items;
		FEmptyContainerStruct Item;
		Items.Add(Item);
		Items.Add(Item);
		return Items.Num();
	}

	/**
	 * Observe that a local int-to-empty map has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a default TMap of int to FEmptyContainerStruct
	 * @Return 0
	 * @Boundary empty map
	 */
	UFUNCTION()
	int MapValueEmptyDefault()
	{
		TMap<int, FEmptyContainerStruct> Items;
		return Items.Num();
	}

	/**
	 * Observe two int-to-empty map inserts.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs keys 20 and 21
	 * @Return 2
	 * @Boundary two items
	 */
	UFUNCTION()
	int MapValueTwoItems()
	{
		TMap<int, FEmptyContainerStruct> Items;
		FEmptyContainerStruct Item;
		Items.Add(20, Item);
		Items.Add(21, Item);
		return Items.Num();
	}

	/**
	 * Observe that copying an empty-struct array does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.EmptyContainerArrayAndIntMapCallShapes
	 * @Inputs a copy that received a second Add
	 * @Return true when the original stays Num 1 and the copy is Num 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ArrayCopyIndependence()
	{
		TArray<FEmptyContainerStruct> Original;
		FEmptyContainerStruct Item;
		Original.Add(Item);
		TArray<FEmptyContainerStruct> Copy = Original;
		Copy.Add(Item);
		if (Original.Num() != 1)
		{
			return false;
		}
		return Copy.Num() == 2;
	}
}
/** @end */
