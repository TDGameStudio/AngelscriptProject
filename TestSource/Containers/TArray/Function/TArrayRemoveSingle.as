/**
 * TArray.RemoveSingle removes the first matching element and shifts later
 * elements down, returning how many it removed. Unlike Remove it stops at
 * one match, so duplicates survive. Presence is observed through Num and
 * Contains, then through UFUNCTION in, out, and inout directions.
 * int is the canonical case; other element types repeat the same four
 * entries with a type suffix.
 *
 * @Theme Containers.TArray
 * @Subject TArray.RemoveSingle
 * @Harness Function
 * @Tag Containers.TArray.TArrayRemoveSingle
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayRemoveSingleObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe RemoveSingle: it removes one match and leaves later duplicates.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs TArray<int> [1,2,2,3]; RemoveSingle(2)
	 * @Return true when one 2 is gone, the other remains, and order is [1,2,3]
	 */
	UFUNCTION()
	bool RemoveSingleDropsOnlyFirstMatch()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(2);
		Array.Add(3);

		int Removed = Array.RemoveSingle(2);
		if (Removed != 1)
		{
			return false;
		}
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
	 * Observe RemoveSingle on a value that is not present: it removes nothing
	 * and leaves the array untouched.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs TArray<int> [1,2,3]; RemoveSingle(99)
	 * @Return true when the return is 0 and the array is unchanged
	 */
	UFUNCTION()
	bool RemoveSingleMissingValueRemovesNothing()
	{
		TArray<int> Array;
		Array.Add(1);
		Array.Add(2);
		Array.Add(3);

		int Removed = Array.RemoveSingle(99);
		if (Removed != 0)
		{
			return false;
		}
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
	 * Observe RemoveSingle on an empty array: it is a legal no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs Empty TArray<int>; RemoveSingle(1)
	 * @Return true when the return is 0 and Num stays 0
	 */
	UFUNCTION()
	bool RemoveSingleOnEmptyIsNoOp()
	{
		TArray<int> Array;

		int Removed = Array.RemoveSingle(1);
		if (Removed != 0)
		{
			return false;
		}
		return Array.Num() == 0;
	}

	/**
	 * In-only: read post-RemoveSingle order from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds [1,2,3]
	 * @Return true when Num is 3 and the order is [1,2,3]
	 */
	UFUNCTION()
	bool ReadAfterRemoveSingle(const TArray<int>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != 1)
		{
			return false;
		}
		if (Values[1] != 2)
		{
			return false;
		}
		return Values[2] == 3;
	}

	/**
	 * Out-only: fill an &out array and strip one duplicate from it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds [1,2,3] after removing one of two 2s
	 */
	UFUNCTION()
	void FillAndRemoveOneDuplicate(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(2);
		Result.Add(3);
		Result.RemoveSingle(2);
	}

	/**
	 * Inout: remove the single match from an existing array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Values Array received as TArray<int>&inout, holds [1,2,3]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values holds [1,3]
	 */
	UFUNCTION()
	void RemoveMiddleMatch(TArray<int>&inout Values)
	{
		Values.RemoveSingle(2);
	}


	/**
	 * Observe RemoveSingle for FString: one match is dropped, duplicates survive.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs TArray<FString> ["a","b","b","c"]; RemoveSingle("b")
	 * @Return true when one "b" is gone and order is ["a","b","c"]
	 */
	UFUNCTION()
	bool RemoveSingleDropsOnlyFirstMatch_FString()
	{
		TArray<FString> Array;
		Array.Add("a");
		Array.Add("b");
		Array.Add("b");
		Array.Add("c");

		int Removed = Array.RemoveSingle("b");
		if (Removed != 1)
		{
			return false;
		}
		if (Array.Num() != 3)
		{
			return false;
		}
		if (Array[0] != "a")
		{
			return false;
		}
		if (Array[1] != "b")
		{
			return false;
		}
		return Array[2] == "c";
	}

	/**
	 * In-only: read post-RemoveSingle order from a const&in TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds ["a","b","c"]
	 * @Return true when Num is 3 and the order is ["a","b","c"]
	 */
	UFUNCTION()
	bool ReadAfterRemoveSingle_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != "a")
		{
			return false;
		}
		if (Values[1] != "b")
		{
			return false;
		}
		return Values[2] == "c";
	}

	/**
	 * Out-only: fill an &out TArray<FString> and strip one duplicate.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result holds ["a","b","c"]
	 */
	UFUNCTION()
	void FillAndRemoveOneDuplicate_FString(TArray<FString>&out Result)
	{
		Result.Add("a");
		Result.Add("b");
		Result.Add("b");
		Result.Add("c");
		Result.RemoveSingle("b");
	}

	/**
	 * Inout: remove the single match from an existing TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveSingle
	 * @Param Values Array received as TArray<FString>&inout, holds ["a","b","c"]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values holds ["a","c"]
	 */
	UFUNCTION()
	void RemoveMiddleMatch_FString(TArray<FString>&inout Values)
	{
		Values.RemoveSingle("b");
	}
}
