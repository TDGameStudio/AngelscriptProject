/**
 * @version v1
 * @summary Sort orders elements ascending by default, descending when asked. Order is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries with a.
 * @topic Containers
 */
/**
 * @version root
 * @summary Sort orders elements ascending by default, descending when asked. Order is observed locally, then through UFUNCTION in, out, and inout. int is the canonical case; other element types repeat the same four entries with a.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Observe Sort: ascending then descending.
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs TArray<int> [5, 2, 8, 1, 9]; Sort(); Sort(true)
	 * @Return true when the array is [1,2,5,8,9] then [9,8,5,2,1]
	 */
	UFUNCTION()
	bool SortAscendingThenDescending()
	{
		TArray<int> Values;
		Values.Add(5);
		Values.Add(2);
		Values.Add(8);
		Values.Add(1);
		Values.Add(9);
		Values.Sort();
		if (Values.Num() != 5
			|| Values[0] != 1 || Values[1] != 2 || Values[2] != 5
			|| Values[3] != 8 || Values[4] != 9)
		{
			return false;
		}

		Values.Sort(true);
		return Values[0] == 9 && Values[1] == 8 && Values[2] == 5
			&& Values[3] == 2 && Values[4] == 1;
	}

	/**
	 * In-only: read already-sorted order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2, 5, 8, 9]
	 * @Return true when Num() == 5 and elements are [1, 2, 5, 8, 9]
	 */
	UFUNCTION()
	bool ReadSortedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 5
			&& Values[0] == 1 && Values[1] == 2 && Values[2] == 5
			&& Values[3] == 8 && Values[4] == 9;
	}

	/**
	 * Out-only: fill an empty &out array then Sort ascending.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2, 5, 8, 9]
	 */
	UFUNCTION()
	void FillAndSort(TArray<int>&out Result)
	{
		Result.Add(5);
		Result.Add(2);
		Result.Add(8);
		Result.Add(1);
		Result.Add(9);
		Result.Sort();
	}

	/**
	 * Inout: Sort the received unsorted array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Array received as TArray<int>&inout, starts as [5, 2, 8, 1, 9]
	 * @Inputs Values.Num() == 5 with [5, 2, 8, 1, 9]
	 * @Return void; Values becomes [1, 2, 5, 8, 9]
	 */
	UFUNCTION()
	void SortInPlace(TArray<int>&inout Values)
	{
		Values.Sort();
	}

	/**
	 * Observe Sort for float: ascending then descending.
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs unsorted TArray<float>; Sort(); Sort(true)
	 * @Return true when order is ascending then descending
	 */
	UFUNCTION()
	bool SortAscendingThenDescending_float()
	{
		TArray<float> Values;
		Values.Add(5.0f);
		Values.Add(2.0f);
		Values.Add(8.0f);
		Values.Add(1.0f);
		Values.Add(9.0f);
		Values.Sort();
		if (Values.Num() != 5 || !(Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 5.0f && Values[3] == 8.0f && Values[4] == 9.0f))
		{
			return false;
		}
		Values.Sort(true);
		return Values[0] == 9.0f && Values[1] == 8.0f && Values[2] == 5.0f && Values[3] == 2.0f && Values[4] == 1.0f;
	}

	/**
	 * In-only: read already-sorted float order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Source array received as const TArray<float>&in
	 * @Inputs already sorted ascending
	 * @Return true when Num() == 5 and order is ascending
	 */
	UFUNCTION()
	bool ReadSortedOrder_float(const TArray<float>&in Values)
	{
		return Values.Num() == 5 && Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 5.0f && Values[3] == 8.0f && Values[4] == 9.0f;
	}

	/**
	 * Out-only: fill an empty &out float array then Sort ascending.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Result Destination received as TArray<float>&out
	 * @Inputs Empty &out TArray<float>
	 * @Return void; Result is sorted ascending
	 */
	UFUNCTION()
	void FillAndSort_float(TArray<float>&out Result)
	{
		Result.Add(5.0f);
		Result.Add(2.0f);
		Result.Add(8.0f);
		Result.Add(1.0f);
		Result.Add(9.0f);
		Result.Sort();
	}

	/**
	 * Inout: Sort the received unsorted float array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Array received as TArray<float>&inout
	 * @Inputs unsorted five elements
	 * @Return void; Values is sorted ascending
	 */
	UFUNCTION()
	void SortInPlace_float(TArray<float>&inout Values)
	{
		Values.Sort();
	}

	/**
	 * Observe Sort for FString: ascending then descending.
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs unsorted TArray<FString>; Sort(); Sort(true)
	 * @Return true when order is ascending then descending
	 */
	UFUNCTION()
	bool SortAscendingThenDescending_FString()
	{
		TArray<FString> Values;
		Values.Add("echo");
		Values.Add("beta");
		Values.Add("delta");
		Values.Add("alpha");
		Values.Add("charlie");
		Values.Sort();
		if (Values.Num() != 5 || !(Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "charlie" && Values[3] == "delta" && Values[4] == "echo"))
		{
			return false;
		}
		Values.Sort(true);
		return Values[0] == "echo" && Values[1] == "delta" && Values[2] == "charlie" && Values[3] == "beta" && Values[4] == "alpha";
	}

	/**
	 * In-only: read already-sorted FString order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs already sorted ascending
	 * @Return true when Num() == 5 and order is ascending
	 */
	UFUNCTION()
	bool ReadSortedOrder_FString(const TArray<FString>&in Values)
	{
		return Values.Num() == 5 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "charlie" && Values[3] == "delta" && Values[4] == "echo";
	}

	/**
	 * Out-only: fill an empty &out FString array then Sort ascending.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result is sorted ascending
	 */
	UFUNCTION()
	void FillAndSort_FString(TArray<FString>&out Result)
	{
		Result.Add("echo");
		Result.Add("beta");
		Result.Add("delta");
		Result.Add("alpha");
		Result.Add("charlie");
		Result.Sort();
	}

	/**
	 * Inout: Sort the received unsorted FString array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Array received as TArray<FString>&inout
	 * @Inputs unsorted five elements
	 * @Return void; Values is sorted ascending
	 */
	UFUNCTION()
	void SortInPlace_FString(TArray<FString>&inout Values)
	{
		Values.Sort();
	}

	/**
	 * Observe Sort for bool: ascending then descending.
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs [true, false, true, false, true]; Sort(); Sort(true)
	 * @Return true when the array is [false, false, true, true, true] then descending
	 */
	UFUNCTION()
	bool SortAscendingThenDescending_bool()
	{
		TArray<bool> Values;
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		Values.Add(false);
		Values.Add(true);
		Values.Sort();
		if (Values.Num() != 5 || Values[0] != false || Values[1] != false || Values[2] != true || Values[3] != true || Values[4] != true)
		{
			return false;
		}
		Values.Sort(true);
		return Values[0] == true && Values[1] == true && Values[2] == true && Values[3] == false && Values[4] == false;
	}

	/**
	 * In-only: read already-sorted bool order from a const&in array without writing it back.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Source array received as const TArray<bool>&in
	 * @Inputs [false, false, true, true, true]
	 * @Return true when the array is sorted ascending
	 */
	UFUNCTION()
	bool ReadSortedOrder_bool(const TArray<bool>&in Values)
	{
		return Values.Num() == 5 && Values[0] == false && Values[1] == false && Values[2] == true && Values[3] == true && Values[4] == true;
	}

	/**
	 * Out-only: fill an empty &out bool array then Sort ascending.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Result Destination received as TArray<bool>&out
	 * @Inputs Empty &out TArray<bool>
	 * @Return void; Result becomes [false, false, true, true, true]
	 */
	UFUNCTION()
	void FillAndSort_bool(TArray<bool>&out Result)
	{
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Add(false);
		Result.Add(true);
		Result.Sort();
	}

	/**
	 * Inout: Sort the received unsorted bool array in place.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Sort
	 * @Param Values Array received as TArray<bool>&inout
	 * @Inputs [true, false, true, false, true]
	 * @Return void; Values becomes [false, false, true, true, true]
	 */
	UFUNCTION()
	void SortInPlace_bool(TArray<bool>&inout Values)
	{
		Values.Sort();
	}

}
/** @end */
