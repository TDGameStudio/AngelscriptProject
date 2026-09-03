/**
 * Inverse restore: copy Original, transform, inverse, Actual == Original.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Restore
 * @Harness Advance
 * @Tag Containers.TMap.TMapRestore
 * @Namespace TMapTest
 */

namespace TMapTest
{
	/**
	 * Add then Remove the same key restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Inputs Original [10->100, 20->200]; Add(30, 300); Remove(30)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool AddThenRemoveRestoresOriginal()
	{
		TMap<int, int> Original;
		Original.Add(10, 100);
		Original.Add(20, 200);
		TMap<int, int> Actual;
		Actual = Original;
		Actual.Add(30, 300);
		if (Actual.Num() != 3 || Actual[30] != 300)
		{
			return false;
		}

		Actual.Remove(30);
		return Actual == Original;
	}

	/**
	 * Overwrite then Add the original value restores the snapshot.
	 *
	 * @Kind Observe
	 * @Covers TMap.Add
	 * @Inputs Original [10->100]; Add(10, 999); Add(10, 100)
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool OverwriteThenRestoreValue()
	{
		TMap<int, int> Original;
		Original.Add(10, 100);
		TMap<int, int> Actual;
		Actual = Original;
		Actual.Add(10, 999);
		if (Actual[10] != 999)
		{
			return false;
		}

		Actual.Add(10, 100);
		return Actual == Original && Actual.Num() == 1;
	}

	/**
	 * Empty then assign the snapshot restores the original pairs.
	 *
	 * @Kind Observe
	 * @Covers TMap.Empty
	 * @Covers TMap.opAssign
	 * @Inputs Original [10->100, 20->200]; Empty; Actual = Original
	 * @Return true when Actual == Original
	 */
	UFUNCTION()
	bool EmptyThenAssignSnapshotRestoresOriginal()
	{
		TMap<int, int> Original;
		Original.Add(10, 100);
		Original.Add(20, 200);
		TMap<int, int> Actual;
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
	 * @Covers TMap.opIndex
	 * @Param Values Source map received as const TMap<int, int>&in
	 * @Inputs Values == [10->100, 20->200]
	 * @Return true when Num() == 2 and both pairs match
	 */
	UFUNCTION()
	bool ReadRestoredSnapshot(const TMap<int, int>&in Values)
	{
		return Values.Num() == 2 && Values[10] == 100 && Values[20] == 200;
	}

	/**
	 * Out-only: C++ receives the snapshot used by Add/Remove restore.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Param Result Destination received as TMap<int, int>&out
	 * @Inputs Empty &out TMap<int, int>
	 * @Return void; Result becomes [10->100, 20->200]
	 */
	UFUNCTION()
	void FillRestoredSnapshot(TMap<int, int>&out Result)
	{
		Result.Add(10, 100);
		Result.Add(20, 200);
	}

	/**
	 * Inout: Add then Remove key 30. C++ passes [10->100, 20->200].
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Inputs Values.Num() == 2 with 10 and 20
	 * @Return void; Values stays [10->100, 20->200]
	 */
	UFUNCTION()
	void RestoreByAddThenRemove(TMap<int, int>&inout Values)
	{
		Values.Add(30, 300);
		Values.Remove(30);
	}

	/**
	 * Return the snapshot after Add then Remove, for C++ equality.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Add
	 * @Covers TMap.Remove
	 * @Inputs none
	 * @Return TMap [10->100, 20->200]
	 */
	UFUNCTION()
	TMap<int, int> ReturnRestoredSnapshot()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		Values.Add(30, 300);
		Values.Remove(30);
		return Values;
	}
}
