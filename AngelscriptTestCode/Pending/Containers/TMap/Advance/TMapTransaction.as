/**
 * @version v1
 * @summary Snapshot commit and rollback. Missing-key [] Throws stay in Exception/; rollback uses Contains as the guard.
 * @topic Containers
 */
/**
 * @version root
 * @summary Snapshot commit and rollback. Missing-key [] Throws stay in Exception/; rollback uses Contains as the guard.
 * @topic Baseline
 */
namespace TMapTest
{
	/**
	 * Commit: Add then Remove when every key is present.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Inputs [10->100, 20->200]; Add(30, 300); Remove(10)
	 * @Return true when the map is [20->200, 30->300]
	 */
	UFUNCTION()
	bool CommitAddThenRemove()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		Values.Add(30, 300);
		bool Removed = Values.Remove(10);
		return Removed
			&& Values.Num() == 2
			&& Values.Contains(20) && Values[20] == 200
			&& Values.Contains(30) && Values[30] == 300
			&& !Values.Contains(10);
	}

	/**
	 * Rollback: Add succeeds, missing key is skipped, restore the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Covers TMap.Contains
	 * @Covers TMap.opAssign
	 * @Inputs Snapshot [10->100, 20->200]; Working.Add(30, 300); !Contains(99); Working = Snapshot
	 * @Return true when Working and Snapshot are both [10->100, 20->200]
	 */
	UFUNCTION()
	bool RollbackMissingKeyRestoresSnapshot()
	{
		TMap<int, int> Snapshot;
		Snapshot.Add(10, 100);
		Snapshot.Add(20, 200);
		TMap<int, int> Working;
		Working = Snapshot;
		Working.Add(30, 300);
		if (Working.Contains(99))
		{
			Working.Remove(99);
		}
		else
		{
			Working = Snapshot;
		}

		return Working == Snapshot
			&& Snapshot.Num() == 2
			&& Snapshot[10] == 100 && Snapshot[20] == 200;
	}

	/**
	 * In-only: C++ passes the committed map.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values == [20->200, 30->300]
	 * @Return true when Num() == 2 and both pairs match
	 */
	UFUNCTION()
	bool ReadCommittedPairs(const TMap<int, int>&in Values)
	{
		return Values.Num() == 2 && Values[20] == 200 && Values[30] == 300;
	}

	/**
	 * Out-only: run commit locally and write [20->200, 30->300] to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result becomes [20->200, 30->300]
	 */
	UFUNCTION()
	void FillCommittedPairs(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
		Result.Add(30, 300);
		Result.Remove(10);
	}

	/**
	 * Inout: C++ passes [10->100, 20->200]; Add(30) then Remove(10).
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values becomes [20->200, 30->300]
	 */
	UFUNCTION()
	void CommitInPlace(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
		Values.Remove(10);
	}

	/**
	 * Return the committed map for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Inputs none
	 * @Return TMap [20->200, 30->300]
	 */
	UFUNCTION()
	TMap<int, int> ReturnCommittedPairs()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		Values.Add(30, 300);
		Values.Remove(10);
		return Values;
	}

	/**
	 * Inout: snapshot, Add(30), skip missing key, restore. C++ writeback equals input.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Covers TMap.opAssign
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values stays [10->100, 20->200]
	 */
	UFUNCTION()
	void RollbackMissingKeyInPlace(TMap<int, int>&inout Values)
	{
		TMap<int, int> Snapshot;
		Snapshot = Values;
		Values.Add(30, 300);
		if (Values.Contains(99))
		{
			Values.Remove(99);
		}
		else
		{
			Values = Snapshot;
		}
	}

	/**
	 * Return the rolled-back snapshot for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Covers TMap.opAssign
	 * @Inputs none
	 * @Return TMap [10->100, 20->200]
	 */
	UFUNCTION()
	TMap<int, int> ReturnRolledBackSnapshot()
	{
		TMap<int, int> Snapshot;
		Snapshot.Add(10, 100);
		Snapshot.Add(20, 200);
		TMap<int, int> Working;
		Working = Snapshot;
		Working.Add(30, 300);
		if (Working.Contains(99))
		{
			Working.Remove(99);
		}
		else
		{
			Working = Snapshot;
		}

		return Working;
	}
}
/** @end */
