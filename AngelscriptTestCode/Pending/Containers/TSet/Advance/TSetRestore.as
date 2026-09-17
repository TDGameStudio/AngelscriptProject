/**
 * @version v1
 * @summary Inverse restore: copy Original, transform, inverse, Actual == Original.
 * @topic Containers
 */
/**
 * @version root
 * @summary Inverse restore: copy Original, transform, inverse, Actual == Original.
 * @topic Baseline
 */
namespace TSetTest
{
	/**
	 * Add then Remove the same member restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Inputs Original [10, 20]; Add(30); Remove(30)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool AddThenRemoveRestoresOriginal()
	{
		TSet<int> Original;
		Original.Add(10);
		Original.Add(20);
		TSet<int> Actual;
		Actual = Original;
		Actual.Add(30);
		if (Actual.Num() != 3 || !Actual.Contains(30))
		{
			return false;
		}

		Actual.Remove(30);
		return Actual == Original;
	}

	/**
	 * Remove then Add the same member restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Inputs Original [10, 20]; Remove(20); Add(20)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool RemoveThenAddRestoresOriginal()
	{
		TSet<int> Original;
		Original.Add(10);
		Original.Add(20);
		TSet<int> Actual;
		Actual = Original;
		Actual.Remove(20);
		if (Actual.Contains(20) || Actual.Num() != 1)
		{
			return false;
		}

		Actual.Add(20);
		return Actual == Original && Actual.Num() == 2;
	}

	/**
	 * Empty then assign the snapshot restores the original members.
	 *
	 * @Kind Observe
	 * @Covers TSet.Empty
	 * @Covers TSet.opAssign
	 * @Inputs Original [10, 20]; Empty; Actual = Original
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool EmptyThenAssignSnapshotRestoresOriginal()
	{
		TSet<int> Original;
		Original.Add(10);
		Original.Add(20);
		TSet<int> Actual;
		Actual = Original;
		Actual.Empty();
		if (Actual.Num() != 0)
		{
			return false;
		}

		Actual = Original;
		return Actual == Original;
	}

	/**
	 * In-only: C++ passes the restored snapshot.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Source set received as const TSet<int>&in
	 * @Inputs Values == [10, 20]
	 * @Return true when Num() == 2 and both members match
	 */
	UFUNCTION()
	bool ReadRestoredSnapshot(const TSet<int>&in Values)
	{
		return Values.Num() == 2 && Values.Contains(10) && Values.Contains(20);
	}

	/**
	 * Out-only: C++ receives the snapshot used by Add/Remove restore.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Param Result Destination received as TSet<int>&out
	 * @Inputs Empty &out TSet<int>
	 * @Return void; Result becomes [10, 20]
	 */
	UFUNCTION()
	void FillRestoredSnapshot(TSet<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
	}

	/**
	 * Inout: Add then Remove 30. C++ passes [10, 20].
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values stays [10, 20]
	 */
	UFUNCTION()
	void RestoreByAddThenRemove(TSet<int>&inout Values)
	{
		Values.Add(30);
		Values.Remove(30);
	}

	/**
	 * Return the snapshot after Add then Remove, for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Add
	 * @Covers TSet.Remove
	 * @Inputs none
	 * @Return TSet [10, 20]
	 */
	UFUNCTION()
	TSet<int> ReturnRestoredSnapshot()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Remove(30);
		return Values;
	}
}
/** @end */
