/**
 * RemoveSwap and RemoveSingleSwap delete without preserving order: the last
 * element is moved into the removed slot. They trade order for speed, so the
 * observable contract is membership and Num, never sequence. RemoveSingleSwap
 * stops at one match while RemoveSwap takes every match.
 * int is the canonical case; other element types repeat the same entries
 * with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.RemoveSwap
 * @Harness Function
 * @Tag Containers.TArray.TArrayRemoveSwap
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayRemoveSwapObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe RemoveSwap: it removes every match and leaves the survivors,
	 * without preserving their original order.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSwap
	 * @Inputs TArray<int> [1,2,3,2,4]; RemoveSwap(2)
	 * @Return true when both 2s are gone and Num is 3
	 */
	UFUNCTION()
	bool RemoveSwapDropsEveryMatch()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(2);
		Array.Add(4);

		int Removed = Array.RemoveSwap(2);
		if (Removed != 2)
		{
			return false;
		}
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array.Contains(2))
		{
			return false;
		}
		if (!Array.Contains(1))
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
	 * Observe that RemoveSwap does not preserve order: surviving elements may
	 * be rearranged by the swap-from-end behaviour.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSwap
	 * @Inputs TArray<int> [1,2,3,4]; RemoveSwap(1)
	 * @Return true when Num is 3 and the removed value is absent
	 * @Boundary order after swap-removal is unspecified
	 */
	UFUNCTION()
	bool RemoveSwapMembershipHoldsOrderDoesNot()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);
		Array.Add(4);

		Array.RemoveSwap(1);
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
	 * Observe RemoveSwap on a value that is not present: nothing is removed.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSwap
	 * @Inputs TArray<int> [1,2,3]; RemoveSwap(99)
	 * @Return true when the return is 0 and Num stays 3
	 */
	UFUNCTION()
	bool RemoveSwapMissingValueRemovesNothing()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		int Removed = Array.RemoveSwap(99);
		if (Removed != 0)
		{
			return false;
		}
		return Array.Num() == 3;
	}

	/**
	 * Observe RemoveSingleSwap: exactly one match is removed even when several exist.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingleSwap
	 * @Inputs TArray<int> [2,1,2,2]; RemoveSingleSwap(2)
	 * @Return true when one 2 is gone, two remain, and Num is 3
	 */
	UFUNCTION()
	bool RemoveSingleSwapDropsExactlyOneMatch()
	{
		TArray<int> Array;
		Array.Add(2);
		Array.Add(1);
		Array.Add(2);
		Array.Add(2);

		int Removed = Array.RemoveSingleSwap(2);
		if (Removed != 1)
		{
			return false;
		}
		if (Array.Num() != 3)
		{
			return false;
		}

		int Twos = 0;
		for (int Value : Array)
		{
			if (Value == 2)
			{
				Twos = Twos + 1;
			}
		}
		if (Twos != 2)
		{
			return false;
		}
		return Array.Contains(1);
	}

	/**
	 * Observe RemoveSingleSwap on an empty array: it is a legal no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingleSwap
	 * @Inputs Empty TArray<int>; RemoveSingleSwap(1)
	 * @Return true when the return is 0 and Num stays 0
	 */
	UFUNCTION()
	bool RemoveSingleSwapOnEmptyIsNoOp()
	{
		TArray<int> Array;

		int Removed = Array.RemoveSingleSwap(1);
		if (Removed != 0)
		{
			return false;
		}
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveSwap contents from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSwap
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds the survivors of a RemoveSwap
	 * @Return true when Num is 3 and the removed value is absent
	 */
	UFUNCTION()
	bool ReadAfterRemoveSwap(const TArray<int>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values.Contains(2))
		{
			return false;
		}
		if (!Values.Contains(1))
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
	 * Out-only: fill an &out array and swap-remove a value from it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSwap
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds the three survivors
	 */
	UFUNCTION()
	void FillAndSwapRemove(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(2);
		Result.Add(4);
		Result.RemoveSwap(2);
	}

	/**
	 * Inout: swap-remove a single match from an existing array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingleSwap
	 * @Param Values Array received as TArray<int>&inout, holds [2,1,2,2]
	 * @Inputs Values.Num() is 4
	 * @Return void; Values holds three elements with two 2s left
	 */
	UFUNCTION()
	void SwapRemoveOneMatch(TArray<int>&inout Values)
	{
		Values.RemoveSingleSwap(2);
	}


	/**
	 * Observe RemoveSwap for FString: every match is removed.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSwap
	 * @Inputs TArray<FString> ["a","b","c","b"]; RemoveSwap("b")
	 * @Return true when both "b" entries are gone and Num is 2
	 */
	UFUNCTION()
	bool RemoveSwapDropsEveryMatch_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("c");
		Array.Add("b");

		int Removed = Array.RemoveSwap("b");
		if (Removed != 2)
		{
			return false;
		}
		if (Array.Num() != 2)
		{
			return false;
		}
		if (Array.Contains("b"))
		{
			return false;
		}
		if (!Array.Contains("a"))
		{
			return false;
		}
		return Array.Contains("c");
	}

	/**
	 * In-only: read post-RemoveSwap contents from a const&in TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSwap
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds the survivors of a RemoveSwap
	 * @Return true when Num is 2 and "b" is absent
	 */
	UFUNCTION()
	bool ReadAfterRemoveSwap_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 2)
		{
			return false;
		}
		if (Values.Contains("b"))
		{
			return false;
		}
		if (!Values.Contains("a"))
		{
			return false;
		}
		return Values.Contains("c");
	}

	/**
	 * Out-only: fill an &out TArray<FString> and swap-remove a value.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSwap
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result holds ["a","c"]
	 */
	UFUNCTION()
	void FillAndSwapRemove_FString(TArray<FString>&out Result)
	{
		Result.Add("a");
		Result.Add("b");
		Result.Add("c");
		Result.Add("b");
		Result.RemoveSwap("b");
	}

	/**
	 * Inout: swap-remove a single match from an existing TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingleSwap
	 * @Param Values Array received as TArray<FString>&inout, holds ["b","a","b"]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values holds two elements with one "b" left
	 */
	UFUNCTION()
	void SwapRemoveOneMatch_FString(TArray<FString>&inout Values)
	{
		Values.RemoveSingleSwap("b");
	}
}
