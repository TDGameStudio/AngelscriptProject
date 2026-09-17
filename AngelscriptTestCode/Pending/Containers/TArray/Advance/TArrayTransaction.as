/**
 * @version v1
 * @summary Snapshot commit and rollback. Illegal RemoveAt is skipped via IsValidIndex; the Throw path stays in Exception/.
 * @topic Containers
 */
/**
 * @version root
 * @summary Snapshot commit and rollback. Illegal RemoveAt is skipped via IsValidIndex; the Throw path stays in Exception/.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Commit: Add then RemoveSingle when every index is valid.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Covers TArray.RemoveSingle
	 * @Inputs [10, 20]; Add(30); RemoveSingle(10)
	 * @Return true when the array is [20, 30]
	 */
	UFUNCTION()
	bool CommitAddThenRemoveSingle()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		int Removed = Values.RemoveSingle(10);
		return Removed == 1
			&& Values.Num() == 2
			&& Values[0] == 20 && Values[1] == 30;
	}

	/**
	 * Rollback: Add succeeds, illegal RemoveAt is skipped, restore the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TArray.Add
	 * @Covers TArray.IsValidIndex
	 * @Covers TArray.opAssign
	 * @Inputs Snapshot [10, 20, 30]; Working.Add(40); IsValidIndex(99) is false; Working = Snapshot
	 * @Return true when Working and Snapshot are both [10, 20, 30]
	 */
	UFUNCTION()
	bool RollbackInvalidIndexRestoresSnapshot()
	{
		TArray<int> Snapshot;
		Snapshot.Add(10);
		Snapshot.Add(20);
		Snapshot.Add(30);
		TArray<int> Working;
		Working = Snapshot;
		Working.Add(40);
		if (Working.IsValidIndex(99))
		{
			Working.RemoveAt(99);
		}
		else
		{
			Working = Snapshot;
		}

		return Working == Snapshot
			&& Snapshot.Num() == 3
			&& Snapshot[0] == 10 && Snapshot[2] == 30
			&& Working[0] == 10 && Working[2] == 30;
	}

	/**
	 * In-only: C++ passes the committed array [20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [20, 30]
	 * @Return true when Num() == 2 and elements are [20, 30]
	 */
	UFUNCTION()
	bool ReadCommittedOrder(const TArray<int>&in Values)
	{
		return Values.Num() == 2 && Values[0] == 20 && Values[1] == 30;
	}

	/**
	 * Out-only: run commit locally and write [20, 30] to C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Covers TArray.RemoveSingle
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [20, 30]
	 */
	UFUNCTION()
	void FillCommittedOrder(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
		Result.RemoveSingle(10);
	}

	/**
	 * Inout: C++ passes [10, 20]; Add(30) then RemoveSingle(10). Writeback [20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Covers TArray.RemoveSingle
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20]
	 * @Inputs Values.Num() == 2 with [10, 20]
	 * @Return void; Values becomes [20, 30]
	 */
	UFUNCTION()
	void CommitInPlace(TArray<int>&inout Values)
	{
		Values.Add(30);
		Values.RemoveSingle(10);
	}

	/**
	 * Return the committed array for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Covers TArray.RemoveSingle
	 * @Inputs none
	 * @Return TArray [20, 30]
	 */
	UFUNCTION()
	TArray<int> ReturnCommittedOrder()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.RemoveSingle(10);
		return Values;
	}

	/**
	 * Inout: snapshot, Add(40), skip illegal RemoveAt, restore. C++ writeback equals input.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.IsValidIndex
	 * @Covers TArray.opAssign
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values stays [10, 20, 30]
	 */
	UFUNCTION()
	void RollbackInvalidIndexInPlace(TArray<int>&inout Values)
	{
		TArray<int> Snapshot;
		Snapshot = Values;
		Values.Add(40);
		if (Values.IsValidIndex(99))
		{
			Values.RemoveAt(99);
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
	 * @Covers TArray.IsValidIndex
	 * @Covers TArray.opAssign
	 * @Inputs none
	 * @Return TArray [10, 20, 30]
	 */
	UFUNCTION()
	TArray<int> ReturnRolledBackSnapshot()
	{
		TArray<int> Snapshot;
		Snapshot.Add(10);
		Snapshot.Add(20);
		Snapshot.Add(30);
		TArray<int> Working;
		Working = Snapshot;
		Working.Add(40);
		if (Working.IsValidIndex(99))
		{
			Working.RemoveAt(99);
		}
		else
		{
			Working = Snapshot;
		}

		return Working;
	}
}
/** @end */
