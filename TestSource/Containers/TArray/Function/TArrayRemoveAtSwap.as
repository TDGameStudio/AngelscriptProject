/**
 * TArray.RemoveAtSwap deletes by index and moves the last element into the
 * freed slot, so it does not preserve order. It is the index-based
 * counterpart of RemoveSwap: same order trade, addressed by position instead
 * of by value. Membership and Num are the observable contract; sequence is not.
 * int is the canonical case; other element types repeat the same entries
 * with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.RemoveAtSwap
 * @Harness Function
 * @Tag Containers.TArray.TArrayRemoveAtSwap
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayRemoveAtSwapObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe RemoveAtSwap: the element at the index is gone and Num drops by one.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs TArray<int> [1,2,3,4]; RemoveAtSwap(0)
	 * @Return true when 1 is gone, Num is 3, and the survivors remain
	 */
	UFUNCTION()
	bool RemoveAtSwapDropsIndexedElement()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		Array.RemoveAtSwap(0);
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array.Contains(1))
		{
			return false;
		}
		if (!Array.Contains(2))
		{
			return false;
		}
		if (!Array.Contains(3))
		{
			return false;
		}
		return Array.Contains(4);
	}

	/**
	 * Observe that RemoveAtSwap does not preserve order: removing the first of
	 * four moves the last element into slot 0.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs TArray<int> [1,2,3,4]; RemoveAtSwap(0); inspect slot 0
	 * @Return true when slot 0 holds the former last element
	 * @Boundary order after swap-removal is unspecified, but the swap is observable
	 */
	UFUNCTION()
	bool RemoveAtSwapMovesLastIntoSlot()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		Array.RemoveAtSwap(0);
		if (Array.Num() != 3)
		{
			return false;
		}
		return Array[0] == 4;
	}

	/**
	 * Observe RemoveAtSwap on the last index: no element needs to move.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs TArray<int> [1,2,3]; RemoveAtSwap(2)
	 * @Return true when 3 is gone and the first two keep their order
	 */
	UFUNCTION()
	bool RemoveAtSwapOnLastIndexKeepsPrefix()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.RemoveAtSwap(2);
		if (Array.Num() != 2)
		{
			return false;
		}
		if (Array.Contains(3))
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
	 * Observe RemoveAtSwap down to empty: repeated calls clear the array.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs TArray<int> [1,2,3]; RemoveAtSwap(0) three times
	 * @Return true when Num reaches 0
	 */
	UFUNCTION()
	bool RemoveAtSwapCanEmpty()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		Array.RemoveAtSwap(0);
		Array.RemoveAtSwap(0);
		Array.RemoveAtSwap(0);
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveAtSwap contents from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds the survivors of a RemoveAtSwap(0) over [1,2,3,4]
	 * @Return true when Num is 3 and 1 is absent
	 */
	UFUNCTION()
	bool ReadAfterRemoveAtSwap(const TArray<int>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values.Contains(1))
		{
			return false;
		}
		if (!Values.Contains(2))
		{
			return false;
		}
		if (!Values.Contains(3))
		{
			return false;
		}
		return Values.Contains(4);
	}

	/**
	 * Out-only: fill an &out array and swap-remove its first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds the three survivors
	 */
	UFUNCTION()
	void FillAndSwapRemoveAt(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(4);
		Result.RemoveAtSwap(0);
	}

	/**
	 * Inout: swap-remove the first slot of an existing array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Values Array received as TArray<int>&inout, holds [1,2,3,4]
	 * @Inputs Values.Num() is 4
	 * @Return void; Values holds three elements and 1 is gone
	 */
	UFUNCTION()
	void SwapRemoveFirstSlot(TArray<int>&inout Values)
	{
		Values.RemoveAtSwap(0);
	}


	/**
	 * Observe RemoveAtSwap for FString: the indexed element is gone.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs TArray<FString> ["a","b","c","d"]; RemoveAtSwap(0)
	 * @Return true when "a" is gone and Num is 3
	 */
	UFUNCTION()
	bool RemoveAtSwapDropsIndexedElement_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("c");
		Array.Add("d");

		Array.RemoveAtSwap(0);
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array.Contains("a"))
		{
			return false;
		}
		if (!Array.Contains("b"))
		{
			return false;
		}
		if (!Array.Contains("c"))
		{
			return false;
		}
		return Array.Contains("d");
	}

	/**
	 * In-only: read post-RemoveAtSwap contents from a const&in TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds the survivors of a RemoveAtSwap(0)
	 * @Return true when Num is 3 and "a" is absent
	 */
	UFUNCTION()
	bool ReadAfterRemoveAtSwap_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values.Contains("a"))
		{
			return false;
		}
		if (!Values.Contains("b"))
		{
			return false;
		}
		if (!Values.Contains("c"))
		{
			return false;
		}
		return Values.Contains("d");
	}

	/**
	 * Out-only: fill an &out TArray<FString> and swap-remove its first slot.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result holds the three survivors
	 */
	UFUNCTION()
	void FillAndSwapRemoveAt_FString(TArray<FString>&out Result)
	{
		Result.Add("a");
		Result.Add("b");
		Result.Add("c");
		Result.Add("d");
		Result.RemoveAtSwap(0);
	}

	/**
	 * Inout: swap-remove the first slot of an existing TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAtSwap
	 * @Param Values Array received as TArray<FString>&inout, holds ["a","b","c","d"]
	 * @Inputs Values.Num() is 4
	 * @Return void; Values holds three elements and "a" is gone
	 */
	UFUNCTION()
	void SwapRemoveFirstSlot_FString(TArray<FString>&inout Values)
	{
		Values.RemoveAtSwap(0);
	}
}
