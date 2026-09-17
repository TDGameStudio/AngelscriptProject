/**
 * @version v1
 * @summary Inverse restore: copy Original, transform, inverse, Actual == Original. Order cases come back to sorted form, not the pre-shuffle order.
 * @topic Containers
 */
/**
 * @version root
 * @summary Inverse restore: copy Original, transform, inverse, Actual == Original. Order cases come back to sorted form, not the pre-shuffle order.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Insert then RemoveAt at the same index restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TArray.Insert
	 * @Covers TArray.RemoveAt
	 * @Inputs Original [10, 20, 30]; Insert(15, 1); RemoveAt(1)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool InsertThenRemoveAtRestoresOriginal()
	{
		TArray<int> Original;
		Original.Add(10);
		Original.Add(20);
		Original.Add(30);
		TArray<int> Actual;
		Actual = Original;
		Actual.Insert(15, 1);
		if (Actual.Num() != 4 || Actual[1] != 15)
		{
			return false;
		}

		Actual.RemoveAt(1);
		return Actual == Original;
	}

	/**
	 * Append a suffix then RemoveAt the new tail one-by-one restores the snapshot.
	 * Bind RemoveAt takes a single index; there is no range RemoveAt.
	 *
	 * @Kind Observe
	 * @Covers TArray.Append
	 * @Covers TArray.RemoveAt
	 * @Inputs Original [10, 20, 30]; Suffix [40, 50]; Append; RemoveAt last twice
	 * @Return true when mid is [10, 20, 30, 40, 50] and Actual == Original after
	 */
	UFUNCTION()
	bool AppendThenRemoveSuffixRestoresOriginal()
	{
		TArray<int> Original;
		Original.Add(10);
		Original.Add(20);
		Original.Add(30);
		TArray<int> Suffix;
		Suffix.Add(40);
		Suffix.Add(50);
		TArray<int> Actual;
		Actual = Original;
		Actual.Append(Suffix);
		if (!(Actual.Num() == 5
			&& Actual[0] == 10 && Actual[3] == 40 && Actual[4] == 50))
		{
			return false;
		}

		Actual.RemoveAt(Actual.Num() - 1);
		Actual.RemoveAt(Actual.Num() - 1);
		return Actual == Original;
	}

	/**
	 * Reset then Append the snapshot restores the original sequence.
	 *
	 * @Kind Observe
	 * @Covers TArray.Reset
	 * @Covers TArray.Append
	 * @Inputs Original [10, 20, 30]; Reset; Append(Original)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool ResetThenAppendSnapshotRestoresOriginal()
	{
		TArray<int> Original;
		Original.Add(10);
		Original.Add(20);
		Original.Add(30);
		TArray<int> Actual;
		Actual = Original;
		Actual.Reset();
		if (Actual.Num() != 0)
		{
			return false;
		}

		Actual.Append(Original);
		return Actual == Original;
	}

	/**
	 * MoveAssignFrom through a temp and back restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Original [1, 2, 3]; Temp.MoveAssignFrom(Original); Original.MoveAssignFrom(Temp)
	 * @Return true when Original == Snapshot and Temp is empty
	 */
	UFUNCTION()
	bool MoveAssignViaTempRestoresOriginal()
	{
		TArray<int> Original;
		Original.Add(1);
		Original.Add(2);
		Original.Add(3);
		TArray<int> Snapshot;
		Snapshot = Original;
		TArray<int> Temp;
		Temp.MoveAssignFrom(Original);
		if (Original.Num() != 0 || Temp.Num() != 3)
		{
			return false;
		}

		Original.MoveAssignFrom(Temp);
		return Original == Snapshot && Temp.Num() == 0;
	}

	/**
	 * Rotate left then rotate right restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Covers TArray.Add
	 * @Covers TArray.Insert
	 * @Inputs Original [10, 20, 30, 40]; move head to tail; move tail to head
	 * @Return true when mid is [20, 30, 40, 10] and Actual == Original after
	 */
	UFUNCTION()
	bool RotateLeftThenRightRestoresOriginal()
	{
		TArray<int> Original;
		Original.Add(10);
		Original.Add(20);
		Original.Add(30);
		Original.Add(40);
		TArray<int> Actual;
		Actual = Original;
		int Head = Actual[0];
		Actual.RemoveAt(0);
		Actual.Add(Head);
		if (!(Actual.Num() == 4
			&& Actual[0] == 20 && Actual[1] == 30 && Actual[2] == 40 && Actual[3] == 10))
		{
			return false;
		}

		int Tail = Actual.Last();
		Actual.RemoveAt(Actual.Num() - 1);
		Actual.Insert(Tail, 0);
		return Actual == Original;
	}

	/**
	 * Shuffle then Sort equals sorting the snapshot. Come-back is sorted form,
	 * not the pre-shuffle order.
	 *
	 * @Kind Observe
	 * @Covers TArray.Shuffle
	 * @Covers TArray.Sort
	 * @Inputs Original [5, 2, 8, 1, 9]; shuffle a copy; Sort both
	 * @Return true when shuffled-then-sorted equals Sort(Original)
	 */
	UFUNCTION()
	bool ShuffleThenSortEqualsSortedOriginal()
	{
		TArray<int> Original;
		Original.Add(5);
		Original.Add(2);
		Original.Add(8);
		Original.Add(1);
		Original.Add(9);
		TArray<int> Expected;
		Expected = Original;
		Expected.Sort();
		TArray<int> Actual;
		Actual = Original;
		Actual.Shuffle();
		Actual.Sort();
		return Actual == Expected
			&& Actual.Num() == 5
			&& Actual[0] == 1 && Actual[4] == 9;
	}

	/**
	 * Sort is idempotent: Sort(Sort(A)) == Sort(A).
	 *
	 * @Kind Observe
	 * @Covers TArray.Sort
	 * @Inputs [5, 2, 8, 1, 9]; Sort(); Sort() again
	 * @Return true when the second Sort leaves [1, 2, 5, 8, 9]
	 */
	UFUNCTION()
	bool SortTwiceEqualsSortOnce()
	{
		TArray<int> Values;
		Values.Add(5);
		Values.Add(2);
		Values.Add(8);
		Values.Add(1);
		Values.Add(9);
		Values.Sort();
		TArray<int> Once;
		Once = Values;
		Values.Sort();
		return Values == Once && Values[0] == 1 && Values[4] == 9;
	}

	/**
	 * In-only: C++ passes the restored snapshot [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.opIndex
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30]
	 * @Return true when Num() == 3 and elements are [10, 20, 30]
	 */
	UFUNCTION()
	bool ReadRestoredSnapshot(const TArray<int>&in Values)
	{
		return Values.Num() == 3 && Values[0] == 10 && Values[1] == 20 && Values[2] == 30;
	}

	/**
	 * Out-only: C++ receives the snapshot used by Insert/Remove restore.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Add
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result becomes [10, 20, 30]
	 */
	UFUNCTION()
	void FillRestoredSnapshot(TArray<int>&out Result)
	{
		Result.Add(10);
		Result.Add(20);
		Result.Add(30);
	}

	/**
	 * Inout: Insert then RemoveAt at index 1. C++ passes [10, 20, 30] and
	 * checks writeback is still [10, 20, 30].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values stays [10, 20, 30]
	 */
	UFUNCTION()
	void RestoreByInsertThenRemoveAt(TArray<int>&inout Values)
	{
		Values.Insert(15, 1);
		Values.RemoveAt(1);
	}

	/**
	 * Return the snapshot after Insert then RemoveAt, for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Insert
	 * @Covers TArray.RemoveAt
	 * @Inputs none
	 * @Return TArray [10, 20, 30]
	 */
	UFUNCTION()
	TArray<int> ReturnRestoredSnapshot()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Insert(15, 1);
		Values.RemoveAt(1);
		return Values;
	}

	/**
	 * Inout: Shuffle then Sort. C++ compares writeback to a separately sorted copy.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Covers TArray.Sort
	 * @Param Values Array received as TArray<int>&inout
	 * @Inputs Any TArray<int>; after call it is ascending
	 * @Return void; Values is Sort(Shuffle(Values))
	 */
	UFUNCTION()
	void ShuffleThenSortInPlace(TArray<int>&inout Values)
	{
		Values.Shuffle();
		Values.Sort();
	}

	/**
	 * Copy, Shuffle, Sort, return. C++ sorts its own copy of Values and compares.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Shuffle
	 * @Covers TArray.Sort
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Any TArray<int>
	 * @Return TArray equal to Sort(Values)
	 */
	UFUNCTION()
	TArray<int> ReturnShuffledThenSorted(const TArray<int>&in Values)
	{
		TArray<int> Actual;
		Actual = Values;
		Actual.Shuffle();
		Actual.Sort();
		return Actual;
	}

	/**
	 * Inout: Append suffix then drop it. C++ passes [10, 20, 30], writeback unchanged.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Append
	 * @Covers TArray.RemoveAt
	 * @Param Values Array received as TArray<int>&inout, starts as [10, 20, 30]
	 * @Inputs Values.Num() == 3 with [10, 20, 30]
	 * @Return void; Values stays [10, 20, 30]
	 */
	UFUNCTION()
	void RestoreByAppendThenRemoveSuffix(TArray<int>&inout Values)
	{
		TArray<int> Suffix;
		Suffix.Add(40);
		Suffix.Add(50);
		Values.Append(Suffix);
		Values.RemoveAt(Values.Num() - 1);
		Values.RemoveAt(Values.Num() - 1);
	}
}
/** @end */
