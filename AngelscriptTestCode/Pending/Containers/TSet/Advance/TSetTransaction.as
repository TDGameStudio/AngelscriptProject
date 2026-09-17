/**
 * @version v1
 * @summary Snapshot commit and rollback. Missing members use Contains as the guard.
 * @topic Containers
 */
/**
 * @version root
 * @summary Snapshot commit and rollback. Missing members use Contains as the guard.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Commit: Add then Remove when every member is present.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Inputs [10, 20]; Add(30); Remove(10)
	 * @Return true when the set is [20, 30]
	 */
	UFUNCTION()
	bool CommitAddThenRemove()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		bool Removed = Values.Remove(10);
		return Removed
			&& Values.Num() == 2
			&& Values.Contains(20) && Values.Contains(30)
			&& !Values.Contains(10);
	}

	/**
	 * Rollback: Add succeeds, missing member is skipped, restore the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Covers TSet.Contains
	 * @Covers TSet.opAssign
	 * @Inputs Snapshot [10, 20]; Working.Add(30); !Contains(99); Working = Snapshot
	 * @Return true when Working and Snapshot are both [10, 20]
	 */
	UFUNCTION()
	bool RollbackMissingMemberRestoresSnapshot()
	{
		TSet<int> Snapshot;
		Snapshot.Add(10);
		Snapshot.Add(20);
		TSet<int> Working;
		Working = Snapshot;
		Working.Add(30);
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
			&& Snapshot.Contains(10) && Snapshot.Contains(20);
	}

	/**
	 * In-only: C++ passes the committed set.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values == [20, 30]
	 * @Return true when Num() == 2 and both members match
	 */
	UFUNCTION()
	bool ReadCommittedMembers(const TSet<int>&in Values)
	{
		return Values.Num() == 2 && Values.Contains(20) && Values.Contains(30);
	}

	/**
	 * Out-only: run commit locally and write [20, 30] to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result becomes [20, 30]
	 */
	UFUNCTION()
	void FillCommittedMembers(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.Remove(10);
	}

	/**
	 * Inout: C++ passes [10, 20]; Add(30) then Remove(10).
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values becomes [20, 30]
	 */
	UFUNCTION()
	void CommitInPlace(TSet<int>&inout Values)
	{
		Values.Add(30);
		Values.Remove(10);
	}

	/**
	 * Return the committed set for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Inputs none
	 * @Return TSet [20, 30]
	 */
	UFUNCTION()
	TSet<int> ReturnCommittedMembers()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Remove(10);
		return Values;
	}

	/**
	 * Inout: snapshot, Add(30), skip missing member, restore. C++ writeback equals input.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Covers TSet.opAssign
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values stays [10, 20]
	 */
	UFUNCTION()
	void RollbackMissingMemberInPlace(TSet<int>&inout Values)
	{
		TSet<int> Snapshot;
		Snapshot = Values;
		Values.Add(30);
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
	 * @Covers TSet.Contains
	 * @Covers TSet.opAssign
	 * @Inputs none
	 * @Return TSet [10, 20]
	 */
	UFUNCTION()
	TSet<int> ReturnRolledBackSnapshot()
	{
		TSet<int> Snapshot;
		Snapshot.Add(10);
		Snapshot.Add(20);
		TSet<int> Working;
		Working = Snapshot;
		Working.Add(30);
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
