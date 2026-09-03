/**
 * Parallel sidecar tables stay aligned under the same key mutation.
 * Values is a TMap; Ids is a TArray of live keys that must match Contains.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Sidecar
 * @Harness Advance
 * @Tag Containers.TMap.TMapSidecar
 * @Namespace TMapTest
 */

namespace TMapTest
{
	/**
	 * Remove the same key from the map and drop it from the id list.
	 *
	 * @Kind Observe
	 * @Covers TMap.Remove
	 * @Covers TArray.Remove
	 * @Inputs Values [10->100, 20->200, 30->300] with Ids [10, 20, 30]; Remove 20
	 * @Return true when both tables drop 20 and lookup of 30 still hits
	 */
	UFUNCTION()
	bool SidecarRemoveKeepsIdsAligned()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		Values.Add(20, 200);
		Values.Add(30, 300);
		TArray<int> Ids;
		Ids.Add(10);
		Ids.Add(20);
		Ids.Add(30);
		Values.Remove(20);
		Ids.Remove(20);
		return Values.Num() == Ids.Num()
			&& Values.Num() == 2
			&& Values.Contains(10) && Values.Contains(30)
			&& !Values.Contains(20)
			&& Ids.Contains(10) && Ids.Contains(30)
			&& !Ids.Contains(20)
			&& Values[30] == 300;
	}

	/**
	 * In-only: C++ passes aligned leftovers.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Remaining map as const TMap<int, int>&in
	 * @Param Ids Remaining ids as const TArray<int>&in
	 * @Inputs Values has 10 and 30; Ids is [10, 30]
	 * @Return true when lengths match and 30 maps to 300
	 */
	UFUNCTION()
	bool ReadSidecarAligned(const TMap<int, int>&in Values, const TArray<int>&in Ids)
	{
		return Values.Num() == Ids.Num()
			&& Values.Num() == 2
			&& Values.Contains(10) && Values.Contains(30)
			&& Ids.Contains(10) && Ids.Contains(30)
			&& Values[30] == 300;
	}

	/**
	 * Inout: Remove key 20 from both tables.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Map received as TMap<int, int>&inout
	 * @Param Ids Ids received as TArray<int>&inout
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return void; 20 is gone from both
	 */
	UFUNCTION()
	void RemoveSidecarMiddle(TMap<int, int>&inout Values, TArray<int>&inout Ids)
	{
		Values.Remove(20);
		Ids.Remove(20);
	}

	/**
	 * Look up the map value for a sidecar id. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Contains
	 * @Param Values Map as const TMap<int, int>&in
	 * @Param Ids Ids as const TArray<int>&in
	 * @Param Id Key to find
	 * @Inputs Aligned tables; Id present or missing
	 * @Return Values[Id], or -1 when missing or lengths differ
	 */
	UFUNCTION()
	int LookupSidecarValue(const TMap<int, int>&in Values, const TArray<int>&in Ids, int Id)
	{
		if (Values.Num() != Ids.Num() || !Ids.Contains(Id) || !Values.Contains(Id))
		{
			return -1;
		}

		return Values[Id];
	}

	/**
	 * Copy both tables, Remove 20, return remaining map for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TMap.Remove
	 * @Param Values Source map as const TMap<int, int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return TMap without key 20
	 */
	UFUNCTION()
	TMap<int, int> ReturnValuesAfterSidecarRemove(const TMap<int, int>&in Values, const TArray<int>&in Ids)
	{
		TMap<int, int> OutValues;
		OutValues = Values;
		TArray<int> OutIds;
		OutIds = Ids;
		OutValues.Remove(20);
		OutIds.Remove(20);
		return OutValues;
	}

	/**
	 * Copy both tables, Remove 20, return remaining ids for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Remove
	 * @Param Values Source map as const TMap<int, int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return TArray without 20
	 */
	UFUNCTION()
	TArray<int> ReturnIdsAfterSidecarRemove(const TMap<int, int>&in Values, const TArray<int>&in Ids)
	{
		TMap<int, int> OutValues;
		OutValues = Values;
		TArray<int> OutIds;
		OutIds = Ids;
		OutValues.Remove(20);
		OutIds.Remove(20);
		return OutIds;
	}
}
