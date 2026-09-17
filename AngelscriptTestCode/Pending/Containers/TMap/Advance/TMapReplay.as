/**
 * @version v1
 * @summary Replay a fixed operation log. Gold is hand-written, not computed by the same APIs under test. Membership, not iteration order.
 * @topic Containers
 */
/**
 * @version root
 * @summary Replay a fixed operation log. Gold is hand-written, not computed by the same APIs under test. Membership, not iteration order.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Replay a fixed op log onto an empty map.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Covers TMap.Empty
	 * @Covers TMap.FindOrAdd
	 * @Inputs []; Add; overwrite; Remove; Empty; FindOrAdd gold
	 * @Return true when the map is [1->10, 2->20]
	 */
	UFUNCTION()
	bool ReplayFixedOpLog()
	{
		TMap<int, int> Values;
		Values.Add(7, 70);
		Values.Add(3, 30);
		Values.Add(7, 71);
		Values.Remove(3);
		Values.Empty();
		Values.FindOrAdd(1) = 10;
		Values.FindOrAdd(2) = 20;
		return Values.Num() == 2 && Values[1] == 10 && Values[2] == 20;
	}

	/**
	 * In-only: C++ passes the replay gold.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values == [1->10, 2->20]
	 * @Return true when Num() == 2 and both pairs match
	 */
	UFUNCTION()
	bool ReadReplayedLog(const TMap<int, int>&in Values)
	{
		return Values.Num() == 2 && Values[1] == 10 && Values[2] == 20;
	}

	/**
	 * Out-only: replay the log into an empty &out for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result becomes [1->10, 2->20]
	 */
	UFUNCTION()
	void FillReplayedLog(TMap<int, int>&out Result)
	{
		Result.Add(7, 70);
		Result.Add(3, 30);
		Result.Add(7, 71);
		Result.Remove(3);
		Result.Empty();
		Result.FindOrAdd(1) = 10;
		Result.FindOrAdd(2) = 20;
	}

	/**
	 * Inout: Empty then replay. C++ writeback is always the gold.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Empty
	 * @Covers TMap.FindOrAdd
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Any TMap<int, int>
	 * @Return void; Values becomes [1->10, 2->20]
	 */
	UFUNCTION()
	void ReplayLogInPlace(TMap<int, int>&inout Values)
	{
		Values.Empty();
		Values.Add(7, 70);
		Values.Add(3, 30);
		Values.Add(7, 71);
		Values.Remove(3);
		Values.Empty();
		Values.FindOrAdd(1) = 10;
		Values.FindOrAdd(2) = 20;
	}

	/**
	 * Return the replay gold for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.FindOrAdd
	 * @Inputs none
	 * @Return TMap [1->10, 2->20]
	 */
	UFUNCTION()
	TMap<int, int> ReturnReplayedLog()
	{
		TMap<int, int> Values;
		Values.Add(7, 70);
		Values.Add(3, 30);
		Values.Add(7, 71);
		Values.Remove(3);
		Values.Empty();
		Values.FindOrAdd(1) = 10;
		Values.FindOrAdd(2) = 20;
		return Values;
	}
}
/** @end */
