/**
 * Replay a fixed operation log. Gold is hand-written, not computed by the
 * same APIs under test.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Replay
 * @Harness Advance
 * @Tag Containers.TArray.TArrayReplay
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Replay a fixed op log onto an empty array.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Covers TArray.Insert
	 * @Covers TArray.RemoveAt
	 * @Covers TArray.AddUnique
	 * @Covers TArray.Empty
	 * @Covers TArray.Append
	 * @Inputs []; Add(7); Insert(3, 0); RemoveAt(1); AddUnique(7); Empty; Append [1, 2]
	 * @Return true when the array is [1, 2]
	 */
	UFUNCTION()
	bool ReplayFixedOpLog()
	{
		TArray<int> Values;
		Values.Add(7);
		Values.Insert(3, 0);
		Values.RemoveAt(1);
		Values.AddUnique(7);
		Values.Empty();
		TArray<int> Tail;
		Tail.Add(1);
		Tail.Add(2);
		Values.Append(Tail);
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * In-only: C++ passes the replay gold [1, 2].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [1, 2]
	 * @Return true when Num() == 2 and elements are [1, 2]
	 */
	UFUNCTION()
	bool ReadReplayedLog(const TArray<int>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
	}

	/**
	 * Out-only: replay the log into an empty &out for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Covers TArray.Append
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [1, 2]
	 */
	UFUNCTION()
	void FillReplayedLog(TArray<int>&out Result)
	{
		Result.Add(7);
		Result.Insert(3, 0);
		Result.RemoveAt(1);
		Result.AddUnique(7);
		Result.Empty();
		TArray<int> Tail;
		Tail.Add(1);
		Tail.Add(2);
		Result.Append(Tail);
	}

	/**
	 * Inout: Empty then replay. C++ writeback is always the gold [1, 2].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Empty
	 * @Covers TArray.Append
	 * @Param Values Array received as TArray<int>&inout
	 * @Inputs Any TArray<int>
	 * @Return void; Values becomes [1, 2]
	 */
	UFUNCTION()
	void ReplayLogInPlace(TArray<int>&inout Values)
	{
		Values.Empty();
		Values.Add(7);
		Values.Insert(3, 0);
		Values.RemoveAt(1);
		Values.AddUnique(7);
		Values.Empty();
		TArray<int> Tail;
		Tail.Add(1);
		Tail.Add(2);
		Values.Append(Tail);
	}

	/**
	 * Return the replay gold for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Inputs none
	 * @Return TArray [1, 2]
	 */
	UFUNCTION()
	TArray<int> ReturnReplayedLog()
	{
		TArray<int> Values;
		Values.Add(7);
		Values.Insert(3, 0);
		Values.RemoveAt(1);
		Values.AddUnique(7);
		Values.Empty();
		TArray<int> Tail;
		Tail.Add(1);
		Tail.Add(2);
		Values.Append(Tail);
		return Values;
	}
}
