/**
 * Replay a fixed operation log. Gold is hand-written, not computed by the
 * same APIs under test. Membership, not iteration order.
 *
 * @Theme Containers.TSet
 * @Subject TSet.Replay
 * @Harness Advance
 * @Tag Containers.TSet.TSetReplay
 * @Namespace TSetTest
 */

namespace TSetTest
{
	/**
	 * Replay a fixed op log onto an empty set.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Covers TSet.Empty
	 * @Inputs []; Add; duplicate Add; Remove; Empty; Add gold
	 * @Return true when the set is [1, 2]
	 */
	UFUNCTION()
	bool ReplayFixedOpLog()
	{
		TSet<int> Values;
		Values.Add(7);
		Values.Add(3);
		Values.Add(7);
		Values.Remove(3);
		Values.Empty();
		Values.Add(1);
		Values.Add(2);
		return Values.Num() == 2 && Values.Contains(1) && Values.Contains(2);
	}

	/**
	 * In-only: C++ passes the replay gold.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values == [1, 2]
	 * @Return true when Num() == 2 and both members match
	 */
	UFUNCTION()
	bool ReadReplayedLog(const TSet<int>&in Values)
	{
		return Values.Num() == 2 && Values.Contains(1) && Values.Contains(2);
	}

	/**
	 * Out-only: replay the log into an empty &out for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result becomes [1, 2]
	 */
	UFUNCTION()
	void FillReplayedLog(TSet<int>&out Result)
	{
		Result.Add(7);
		Result.Add(3);
		Result.Add(7);
		Result.Remove(3);
		Result.Empty();
		Result.Add(1);
		Result.Add(2);
	}

	/**
	 * Inout: Empty then replay. C++ writeback is always the gold.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Empty
	 * @Covers TSet.Add
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Any TSet<int>
	 * @Return void; Values becomes [1, 2]
	 */
	UFUNCTION()
	void ReplayLogInPlace(TSet<int>&inout Values)
	{
		Values.Empty();
		Values.Add(7);
		Values.Add(3);
		Values.Add(7);
		Values.Remove(3);
		Values.Empty();
		Values.Add(1);
		Values.Add(2);
	}

	/**
	 * Return the replay gold for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Inputs none
	 * @Return TSet [1, 2]
	 */
	UFUNCTION()
	TSet<int> ReturnReplayedLog()
	{
		TSet<int> Values;
		Values.Add(7);
		Values.Add(3);
		Values.Add(7);
		Values.Remove(3);
		Values.Empty();
		Values.Add(1);
		Values.Add(2);
		return Values;
	}
}
