/**
 * Parallel sidecar tables stay aligned under the same index mutation.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Sidecar
 * @Harness Advance
 * @Tag Containers.TArray.TArraySidecar
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * Values and Ids RemoveAt the same index; FindIndex still maps to the id.
	 *
	 * @Kind Observe
	 * @Covers TArray.RemoveAt
	 * @Covers TArray.FindIndex
	 * @Inputs Values [10, 20, 30] with Ids [100, 200, 300]; RemoveAt(1) on both
	 * @Return true when both arrays are [10, 30] / [100, 300] and FindIndex(30)==1
	 */
	UFUNCTION()
	bool SidecarRemoveAtKeepsIdsAligned()
	{
		TArray<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		TArray<int> Ids;
		Ids.Add(100);
		Ids.Add(200);
		Ids.Add(300);
		Values.RemoveAt(1);
		Ids.RemoveAt(1);
		int ValueIndex = Values.FindIndex(30);
		return Values.Num() == Ids.Num()
			&& Values.Num() == 2
			&& Values[0] == 10 && Values[1] == 30
			&& Ids[0] == 100 && Ids[1] == 300
			&& ValueIndex == 1
			&& Ids[ValueIndex] == 300
			&& Values.FindIndex(20) == -1;
	}

	/**
	 * In-only: C++ passes aligned leftovers [10, 30] and [100, 300].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Remaining values as const TArray<int>&in
	 * @Param Ids Remaining ids as const TArray<int>&in
	 * @Inputs Values == [10, 30] and Ids == [100, 300]
	 * @Return true when lengths match and FindIndex(30) maps to id 300
	 */
	UFUNCTION()
	bool ReadSidecarAligned(const TArray<int>&in Values, const TArray<int>&in Ids)
	{
		int ValueIndex = Values.FindIndex(30);
		return Values.Num() == Ids.Num()
			&& Values.Num() == 2
			&& Values[0] == 10 && Values[1] == 30
			&& Ids[0] == 100 && Ids[1] == 300
			&& ValueIndex == 1
			&& Ids[ValueIndex] == 300;
	}

	/**
	 * Inout: RemoveAt(1) on both tables. C++ passes [10,20,30] / [100,200,300].
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Values received as TArray<int>&inout
	 * @Param Ids Ids received as TArray<int>&inout
	 * @Inputs Values == [10, 20, 30] and Ids == [100, 200, 300]
	 * @Return void; Values [10, 30], Ids [100, 300]
	 */
	UFUNCTION()
	void RemoveSidecarMiddle(TArray<int>&inout Values, TArray<int>&inout Ids)
	{
		Values.RemoveAt(1);
		Ids.RemoveAt(1);
	}

	/**
	 * Look up the sidecar id for a value. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.FindIndex
	 * @Param Values Values as const TArray<int>&in
	 * @Param Ids Ids as const TArray<int>&in
	 * @Param Value Element to find
	 * @Inputs Aligned tables; Value present or missing
	 * @Return Ids[FindIndex(Value)], or -1 when missing or lengths differ
	 */
	UFUNCTION()
	int LookupSidecarId(const TArray<int>&in Values, const TArray<int>&in Ids, int Value)
	{
		if (Values.Num() != Ids.Num())
		{
			return -1;
		}

		int Index = Values.FindIndex(Value);
		if (Index < 0)
		{
			return -1;
		}

		return Ids[Index];
	}

	/**
	 * Copy both tables, RemoveAt(1), return remaining values for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source values as const TArray<int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30] and Ids == [100, 200, 300]
	 * @Return TArray [10, 30]
	 */
	UFUNCTION()
	TArray<int> ReturnValuesAfterSidecarRemove(const TArray<int>&in Values, const TArray<int>&in Ids)
	{
		TArray<int> OutValues;
		OutValues = Values;
		TArray<int> OutIds;
		OutIds = Ids;
		OutValues.RemoveAt(1);
		OutIds.RemoveAt(1);
		return OutValues;
	}

	/**
	 * Copy both tables, RemoveAt(1), return remaining ids for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.RemoveAt
	 * @Param Values Source values as const TArray<int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values == [10, 20, 30] and Ids == [100, 200, 300]
	 * @Return TArray [100, 300]
	 */
	UFUNCTION()
	TArray<int> ReturnIdsAfterSidecarRemove(const TArray<int>&in Values, const TArray<int>&in Ids)
	{
		TArray<int> OutValues;
		OutValues = Values;
		TArray<int> OutIds;
		OutIds = Ids;
		OutValues.RemoveAt(1);
		OutIds.RemoveAt(1);
		return OutIds;
	}
}
