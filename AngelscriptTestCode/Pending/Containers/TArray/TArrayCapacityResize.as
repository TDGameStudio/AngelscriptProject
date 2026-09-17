/**
 * @version v1
 * @summary Shrink, GetAllocatedSize, SetNum, and SetNumZeroed are the capacity and resize surface. Shrink releases unused slack; GetAllocatedSize reports the bytes currently allocated; SetNum resizes and default-constructs added.
 * @topic Containers
 */
/**
 * @version root
 * @summary Shrink, GetAllocatedSize, SetNum, and SetNumZeroed are the capacity and resize surface. Shrink releases unused slack; GetAllocatedSize reports the bytes currently allocated; SetNum resizes and default-constructs added.
 * @topic Baseline
 */
UCLASS()
class UTArrayCapacityResizeObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Shrink: it releases unused slack so Max() drops back toward Num().
	 *
	 * @Kind Observe
	 * @Covers TArray.Shrink
	 * @Inputs TArray<int>; Reserve(64); Add one; Shrink()
	 * @Return true when Max() is no longer 64 after the shrink
	 */
	UFUNCTION()
	bool ShrinkReleasesUnusedSlack()
	{
		TArray<int> Array;
		Array.Reserve(64);
		Array.Add(1);

		if (Array.Max() < 64)
		{
			return false;
		}

		Array.Shrink();
		if (Array.Num() != 1)
		{
			return false;
		}
		return Array.Max() < 64;
	}

	/**
	 * Observe that Shrink keeps the elements: it releases capacity, not contents.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shrink
	 * @Inputs TArray<int> [1,2,3]; Reserve(64); Shrink()
	 * @Return true when all three elements survive
	 */
	UFUNCTION()
	bool ShrinkKeepsElements()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Reserve(64);

		Array.Shrink();
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array[0] != 1)
		{
			return false;
		}
		if (Array[1] != 2)
		{
			return false;
		}
		return Array[2] == 3;
	}

	/**
	 * Observe that Shrink is legal on an empty array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shrink
	 * @Inputs Empty TArray<int>; Shrink()
	 * @Return true when Num stays 0
	 */
	UFUNCTION()
	bool ShrinkOnEmptyIsNoOp()
	{
		TArray<int> Array;

		Array.Shrink();
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.IsEmpty();
	}

	/**
	 * Observe GetAllocatedSize: it grows with the element count and is zero for
	 * a default-constructed array.
	 *
	 * @Kind Observe
	 * @Covers TArray.GetAllocatedSize
	 * @Inputs Empty TArray<int>; read size; Add four; read size again
	 * @Return true when the empty array reports 0 and the filled one reports more
	 */
	UFUNCTION()
	bool GetAllocatedSizeGrowsWithElements()
	{
		TArray<int> Array;

		int64 EmptySize = Array.GetAllocatedSize();
		if (EmptySize != 0)
		{
			return false;
		}

		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		int64 FilledSize = Array.GetAllocatedSize();
		if (FilledSize <= 0)
		{
			return false;
		}
		return FilledSize >= 4;
	}

	/**
	 * Observe GetAllocatedSize after Shrink: capacity released shows up as a
	 * smaller allocated size.
	 *
	 * @Kind Observe
	 * @Covers TArray.GetAllocatedSize
	 * @Inputs TArray<int>; Reserve(64); read size; Shrink(); read size again
	 * @Return true when the size after shrink is smaller than before
	 */
	UFUNCTION()
	bool GetAllocatedSizeDropsAfterShrink()
	{
		TArray<int> Array;
		Array.Reserve(64);
		Array.Add(1);

		int64 BeforeShrink = Array.GetAllocatedSize();
		Array.Shrink();
		int64 AfterShrink = Array.GetAllocatedSize();

		if (BeforeShrink <= 0)
		{
			return false;
		}
		if (AfterShrink <= 0)
		{
			return false;
		}
		return AfterShrink < BeforeShrink;
	}

	/**
	 * Observe SetNum growing: added slots are default-constructed.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs TArray<int> [1,2]; SetNum(4)
	 * @Return true when Num is 4 and the original two keep their values
	 */
	UFUNCTION()
	bool SetNumGrowsAndKeepsPrefix()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);

		Array.SetNum(4);
		if (Array.Num() != 4)
		{
			return false;
		}
		if (Array[0] != 1)
		{
			return false;
		}
		return Array[1] == 2;
	}

	/**
	 * Observe SetNum shrinking: the array is truncated and the dropped slots are gone.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs TArray<int> [1,2,3,4]; SetNum(2)
	 * @Return true when Num is 2 and the first two survive
	 */
	UFUNCTION()
	bool SetNumShrinksAndKeepsPrefix()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		Array.SetNum(2);
		if (Array.Num() != 2)
		{
			return false;
		}
		if (Array[0] != 1)
		{
			return false;
		}
		return Array[1] == 2;
	}

	/**
	 * Observe SetNum(0): it empties the array.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNum
	 * @Inputs TArray<int> [1,2,3]; SetNum(0)
	 * @Return true when Num is 0 and IsEmpty() is true
	 */
	UFUNCTION()
	bool SetNumZeroEmptiesArray()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.SetNum(0);
		if (Array.Num() != 0)
		{
			return false;
		}
		return Array.IsEmpty();
	}

	/**
	 * Observe SetNumZeroed growing: added slots are zeroed for a primitive type.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNumZeroed
	 * @Inputs TArray<int> [7]; SetNumZeroed(3)
	 * @Return true when Num is 3, slot 0 keeps 7, and added slots are 0
	 */
	UFUNCTION()
	bool SetNumZeroedZeroesAddedSlots()
	{
		TArray<int> Array;
		Array.Add(7);

		Array.SetNumZeroed(3);
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array[0] != 7)
		{
			return false;
		}
		if (Array[1] != 0)
		{
			return false;
		}
		return Array[2] == 0;
	}

	/**
	 * Observe SetNumZeroed shrinking: it truncates like SetNum.
	 *
	 * @Kind Observe
	 * @Covers TArray.SetNumZeroed
	 * @Inputs TArray<int> [1,2,3]; SetNumZeroed(1)
	 * @Return true when Num is 1 and slot 0 keeps its value
	 */
	UFUNCTION()
	bool SetNumZeroedShrinksAndKeepsPrefix()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.SetNumZeroed(1);
		if (Array.Num() != 1)
		{
			return false;
		}
		return Array[0] == 1;
	}

	/**
	 * In-only: read the resized length from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.SetNum
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values was resized to 4
	 * @Return true when Num is 4
	 */
	UFUNCTION()
	bool ReadResizedLength(const TArray<int>&in Values)
	{
		return Values.Num() == 4;
	}

	/**
	 * Out-only: fill an &out array and grow it with SetNum.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.SetNum
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds four elements
	 */
	UFUNCTION()
	void FillAndGrow(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.SetNum(4);
	}

	/**
	 * Inout: shrink an existing array with SetNum.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.SetNum
	 * @Param Values Array received as TArray<int>&inout, holds [1,2,3,4]
	 * @Inputs Values.Num() is 4
	 * @Return void; Values holds two elements
	 */
	UFUNCTION()
	void ShrinkBySetNum(TArray<int>&inout Values)
	{
		Values.SetNum(2);
	}

	/**
	 * Inout: release slack on an existing array with Shrink.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shrink
	 * @Param Values Array received as TArray<int>&inout, holds [1] with reserved slack
	 * @Inputs Values.Max() is larger than Values.Num()
	 * @Return void; Values has released its unused slack
	 */
	UFUNCTION()
	void ReleaseSlack(TArray<int>&inout Values)
	{
		Values.Shrink();
	}
}
/** @end */
