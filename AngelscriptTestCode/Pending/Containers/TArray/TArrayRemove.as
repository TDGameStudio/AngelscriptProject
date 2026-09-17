/**
 * @version v1
 * @summary Value and swap removals. RemoveAt (shift) is TArrayRemoveAt.as. Remove-all-matches is the RoundTrip surface; other overloads stay Observe. int is the canonical case; other element types repeat the same four entries with.
 * @topic Containers
 */
/**
 * @version root
 * @summary Value and swap removals. RemoveAt (shift) is TArrayRemoveAt.as. Remove-all-matches is the RoundTrip surface; other overloads stay Observe. int is the canonical case; other element types repeat the same four entries with.
 * @topic Baseline
 */
UCLASS()
class UTArrayRemoveObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Remove deletes every match and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [1, 2, 3, 2, 4, 2, 5]; Remove(2)
	 * @Return true when removed count is 3 and the array is [1, 3, 4, 5]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(2);
		Values.Add(4);
		Values.Add(2);
		Values.Add(5);
		int Removed = Values.Remove(2);
		return Removed == 3
			&& Values.Num() == 4
			&& Values[0] == 1 && Values[1] == 3 && Values[2] == 4 && Values[3] == 5;
	}

	/**
	 * In-only: read post-Remove order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 3, 4, 5]
	 * @Return true when Num() == 4 and elements are [1, 3, 4, 5]
	 */
	UFUNCTION()
	bool ReadRemovedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 4
			&& Values[0] == 1 && Values[1] == 3 && Values[2] == 4 && Values[3] == 5;
	}

	/**
	 * Out-only: fill an empty &out array then Remove every 2.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 3, 4, 5]
	 */
	UFUNCTION()
	void FillArrayByRemove(TArray<int>&out Result)
	{
		Result.Add(1);
		Result.Add(2);
		Result.Add(3);
		Result.Add(2);
		Result.Add(4);
		Result.Add(2);
		Result.Add(5);
		Result.Remove(2);
	}

	/**
	 * Inout: Remove every 2 from an existing [1, 2, 3, 2, 4, 2, 5].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<int>&inout, starts as [1, 2, 3, 2, 4, 2, 5]
	 * @Inputs Values.Num() == 7 with three 2s
	 * @Return void; Values becomes [1, 3, 4, 5]
	 */
	UFUNCTION()
	void RemoveValue(TArray<int>&inout Values)
	{
		Values.Remove(2);
	}

	/**
	 * RemoveSingle deletes only the first match and preserves later order.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs [1, 2, 2, 3]; RemoveSingle(2)
	 * @Return true when removed count is 1 and the array is [1, 2, 3]
	 */
	UFUNCTION()
	bool RemoveSingleDeletesFirstMatch()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(2);
		Values.Add(3);
		int Removed = Values.RemoveSingle(2);
		return Removed == 1
			&& Values.Num() == 3
			&& Values[0] == 1 && Values[1] == 2 && Values[2] == 3;
	}

	/**
	 * RemoveSwap deletes every match; remaining order is not asserted.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSwap
	 * @Inputs [1, 2, 3, 2]; RemoveSwap(2)
	 * @Return true when removed count is 2, Num is 2, and 1 and 3 remain
	 */
	UFUNCTION()
	bool RemoveSwapDeletesAllMatches()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(2);
		int Removed = Values.RemoveSwap(2);
		return Removed == 2
			&& Values.Num() == 2
			&& Values.Contains(1)
			&& Values.Contains(3)
			&& !Values.Contains(2);
	}

	/**
	 * RemoveSingleSwap deletes one match by swapping from the end.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingleSwap
	 * @Inputs [1, 2, 3, 2]; RemoveSingleSwap(2)
	 * @Return true when removed count is 1, Num is 3, and one 2 remains
	 */
	UFUNCTION()
	bool RemoveSingleSwapDeletesOneMatch()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(2);
		int Removed = Values.RemoveSingleSwap(2);
		int Twos = 0;
		for (int Index = 0; Index < Values.Num(); ++Index)
		{
			if (Values[Index] == 2)
			{
				Twos++;
			}
		}
		return Removed == 1 && Values.Num() == 3 && Twos == 1 && Values.Contains(1) && Values.Contains(3);
	}

	/**
	 * RemoveAtSwap drops one index by swapping with the last element.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs [10, 20, 30, 40]; RemoveAtSwap(1)
	 * @Return true when the array is [10, 40, 30]
	 */
	UFUNCTION()
	bool RemoveAtSwapDropsIndex()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Add(40);
		Values.RemoveAtSwap(1);
		return Values.Num() == 3
			&& Values[0] == 10 && Values[1] == 40 && Values[2] == 30;
	}

	/**
	 * RemoveAtSwap on the last index equals RemoveAt: only the tail drops.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAtSwap
	 * @Inputs [10, 20, 30, 40]; RemoveAtSwap(3)
	 * @Return true when the array is [10, 20, 30]
	 */
	UFUNCTION()
	bool RemoveAtSwapLastEqualsRemoveAt()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Add(40);
		Values.RemoveAtSwap(3);
		return Values.Num() == 3
			&& Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
	}

	/**
	 * Remove of a missing value returns 0 and leaves the array unchanged.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [1, 2]; Remove(99); empty Remove(99)
	 * @Return true when both calls return 0, [1, 2] stays, and empty stays empty
	 */
	UFUNCTION()
	bool RemoveMissingLeavesArrayUnchanged()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		int Removed = Values.Remove(99);
		if (Removed != 0 || Values.Num() != 2 || Values[0] != 1 || Values[1] != 2)
		{
			return false;
		}

		TArray<int> Empty;
		return Empty.Remove(99) == 0 && Empty.Num() == 0;
	}

	/**
	 * RemoveSingle of a missing value returns 0 and leaves the array unchanged.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveSingle
	 * @Inputs [1, 2]; RemoveSingle(99); empty RemoveSingle(99)
	 * @Return true when both calls return 0, [1, 2] stays, and empty stays empty
	 */
	UFUNCTION()
	bool RemoveSingleMissingLeavesArrayUnchanged()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		int Removed = Values.RemoveSingle(99);
		if (Removed != 0 || Values.Num() != 2 || Values[0] != 1 || Values[1] != 2)
		{
			return false;
		}

		TArray<int> Empty;
		return Empty.RemoveSingle(99) == 0 && Empty.Num() == 0;
	}

	/**
	 * Remove deletes every matching float and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [a,b,c,b,d,b,e]; Remove(b)
	 * @Return true when removed count is 3 and remaining order is [a,c,d,e]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches_float()
	{
		TArray<float> Values;
		Values.Add(1.0f);
		Values.Add(2.0f);
		Values.Add(3.0f);
		Values.Add(2.0f);
		Values.Add(4.0f);
		Values.Add(2.0f);
		Values.Add(5.0f);
		int Removed = Values.Remove(2.0f);
		return Removed == 3 && Values.Num() == 4 && Values[0] == 1.0f && Values[1] == 3.0f && Values[2] == 4.0f && Values[3] == 5.0f;
	}

	/**
	 * In-only: read post-Remove float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs [a,c,d,e]
	 * @Return true when Num() == 4 and remaining order matches
	 */
	UFUNCTION()
	bool ReadRemovedOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 4 && Values[0] == 1.0f && Values[1] == 3.0f && Values[2] == 4.0f && Values[3] == 5.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then Remove every match.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is [a,c,d,e]
	 */
	UFUNCTION()
	void FillArrayByRemove_float(TArray<float>&out Result)
	{
		Result.Add(1.0f);
		Result.Add(2.0f);
		Result.Add(3.0f);
		Result.Add(2.0f);
		Result.Add(4.0f);
		Result.Add(2.0f);
		Result.Add(5.0f);
		Result.Remove(2.0f);
	}

	/**
	 * Inout: Remove every matching float from the received array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs seven elements with three matches
	 * @Return void; Values becomes [a,c,d,e]
	 */
	UFUNCTION()
	void RemoveValue_float(TArray<float>&inout Values)
	{
		Values.Remove(2.0f);
	}

	/**
	 * Remove deletes every matching FString and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [a,b,c,b,d,b,e]; Remove(b)
	 * @Return true when removed count is 3 and remaining order is [a,c,d,e]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches_FString()
	{
		TArray<FString> Values;
		Values.Add("alpha");
		Values.Add("beta");
		Values.Add("gamma");
		Values.Add("beta");
		Values.Add("delta");
		Values.Add("beta");
		Values.Add("echo");
		int Removed = Values.Remove("beta");
		return Removed == 3 && Values.Num() == 4 && Values[0] == "alpha" && Values[1] == "gamma" && Values[2] == "delta" && Values[3] == "echo";
	}

	/**
	 * In-only: read post-Remove FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs [a,c,d,e]
	 * @Return true when Num() == 4 and remaining order matches
	 */
	UFUNCTION()
	bool ReadRemovedOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 4 && Values[0] == "alpha" && Values[1] == "gamma" && Values[2] == "delta" && Values[3] == "echo";
	}

	/**
	 * Out-only: fill an empty &out FString array then Remove every match.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is [a,c,d,e]
	 */
	UFUNCTION()
	void FillArrayByRemove_FString(TArray<FString>&out Result)
	{
		Result.Add("alpha");
		Result.Add("beta");
		Result.Add("gamma");
		Result.Add("beta");
		Result.Add("delta");
		Result.Add("beta");
		Result.Add("echo");
		Result.Remove("beta");
	}

	/**
	 * Inout: Remove every matching FString from the received array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs seven elements with three matches
	 * @Return void; Values becomes [a,c,d,e]
	 */
	UFUNCTION()
	void RemoveValue_FString(TArray<FString>&inout Values)
	{
		Values.Remove("beta");
	}

	/**
	 * Remove deletes every matching FVector and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [a,b,c,b,d,b,e]; Remove(b)
	 * @Return true when removed count is 3 and remaining order is [a,c,d,e]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches_FVector()
	{
		TArray<FVector> Values;
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 0.0f, 1.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(1.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 0.0f));
		Values.Add(FVector(0.0f, 1.0f, 1.0f));
		int Removed = Values.Remove(FVector(0.0f, 1.0f, 0.0f));
		return Removed == 3 && Values.Num() == 4 && Values[0].Equals(FVector(1.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 0.0f, 1.0f)) && Values[2].Equals(FVector(1.0f, 1.0f, 0.0f)) && Values[3].Equals(FVector(0.0f, 1.0f, 1.0f));
	}

	/**
	 * In-only: read post-Remove FVector order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<FVector>&in
	 * @Inputs [a,c,d,e]
	 * @Return true when Num() == 4 and remaining order matches
	 */
	UFUNCTION()
	bool ReadRemovedOrder_FVector(const TArray<FVector>&in Values)
	{
		return Values.Num() == 4 && Values[0].Equals(FVector(1.0f, 0.0f, 0.0f)) && Values[1].Equals(FVector(0.0f, 0.0f, 1.0f)) && Values[2].Equals(FVector(1.0f, 1.0f, 0.0f)) && Values[3].Equals(FVector(0.0f, 1.0f, 1.0f));
	}

	/**
	 * Out-only: fill an empty &out FVector array then Remove every match.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<FVector>&out
	 * @Inputs Empty &out TArray<FVector>
	 * @Return void; Result is [a,c,d,e]
	 */
	UFUNCTION()
	void FillArrayByRemove_FVector(TArray<FVector>&out Result)
	{
		Result.Add(FVector(1.0f, 0.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 0.0f, 1.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(1.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 0.0f));
		Result.Add(FVector(0.0f, 1.0f, 1.0f));
		Result.Remove(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * Inout: Remove every matching FVector from the received array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<FVector>&inout
	 * @Inputs seven elements with three matches
	 * @Return void; Values becomes [a,c,d,e]
	 */
	UFUNCTION()
	void RemoveValue_FVector(TArray<FVector>&inout Values)
	{
		Values.Remove(FVector(0.0f, 1.0f, 0.0f));
	}

	/**
	 * Remove deletes every matching bool and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [true, false, true, false, true]; Remove(true)
	 * @Return true when removed count is 3 and remaining is [false, false]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches_bool()
	{
		TArray<bool> Values;
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		int Removed = Values.Remove(true);
		return Removed == 3 && Values.Num() == 2 && Values[0] == false && Values[1] == false;
	}

	/**
	 * In-only: read post-Remove bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, false]
	 * @Return true when Num() == 2 and both are false
	 */
	UFUNCTION()
	bool ReadRemovedOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 2 && Values[0] == false && Values[1] == false;
	}

	/**
	 * Out-only: fill an empty &out bool array then Remove every true.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, false]
	 */
	UFUNCTION()
	void FillArrayByRemove_bool(TArray<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Remove(true);
	}

	/**
	 * Inout: Remove every true from the received bool array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [true, false, true, false, true]
	 * @Return void; Values becomes [false, false]
	 */
	UFUNCTION()
	void RemoveValue_bool(TArray<bool>&inout Values)
	{
		Values.Remove(true);
	}

	/**
	 * Remove deletes every matching UObject handle and returns the count.
	 *
	 * @Kind Observe
	 * @Covers TArray.Remove
	 * @Inputs [A,B,C,B,D,B,E]; Remove(B)
	 * @Return true when removed count is 3 and remaining is [A,C,D,E]
	 */
	UFUNCTION()
	bool RemoveDeletesAllMatches_UObject()
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_C", true);
		UObject D = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_D", true);
		UObject E = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_E", true);
		if (A == nullptr || B == nullptr || C == nullptr || D == nullptr || E == nullptr)
		{
			return false;
		}
		TArray<UObject> Values;
		Values.Add(A);
		Values.Add(B);
		Values.Add(C);
		Values.Add(B);
		Values.Add(D);
		Values.Add(B);
		Values.Add(E);
		int Removed = Values.Remove(B);
		return Removed == 3 && Values.Num() == 4 && Values[0] == A && Values[1] == C && Values[2] == D && Values[3] == E;
	}

	/**
	 * In-only: read post-Remove UObject order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source array received as const TArray<UObject>&in
	 * @Inputs four remaining handles
	 * @Return true when Num() == 4
	 */
	UFUNCTION()
	bool ReadRemovedOrder_UObject(const TArray<UObject>&in Values)
	{
		return Values.Num() == 4;
	}

	/**
	 * Out-only: fill an empty &out UObject array then Remove every matching handle.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Result Destination received as TArray<UObject>&out
	 * @Inputs Empty &out TArray<UObject>
	 * @Return void; Result.Num() == 4
	 */
	UFUNCTION()
	void FillArrayByRemove_UObject(TArray<UObject>&out Result)
	{
		UObject A = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_Fill_A", true);
		UObject B = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_Fill_B", true);
		UObject C = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_Fill_C", true);
		UObject D = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_Fill_D", true);
		UObject E = NewObject(GetTransientPackage(), UTArrayRemoveObject::StaticClass(), n"TArrayRemove_Fill_E", true);
		Result.Add(A);
		Result.Add(B);
		Result.Add(C);
		Result.Add(B);
		Result.Add(D);
		Result.Add(B);
		Result.Add(E);
		Result.Remove(B);
	}

	/**
	 * Inout: Remove every matching handle from the received UObject array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Array received as TArray<UObject>&inout
	 * @Inputs seven elements with three copies of Values[1]
	 * @Return void; those copies are removed
	 */
	UFUNCTION()
	void RemoveValue_UObject(TArray<UObject>&inout Values)
	{
		UObject Match = Values[1];
		Values.Remove(Match);
	}

}
/** @end */
