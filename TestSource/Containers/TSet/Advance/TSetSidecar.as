/**
 * Parallel sidecar tables stay aligned under the same member mutation.
 * Values is a TSet; Ids is a TArray of live members that must match Contains.
 *
 * @Theme Containers.TSet
 * @Subject TSet.Sidecar
 * @Harness Advance
 * @Tag Containers.TSet.TSetSidecar
 * @Namespace TSetTest
 */

namespace TSetTest
{
	/**
	 * Remove the same member from the set and drop it from the id list.
	 *
	 * @Kind Observe
	 * @Covers TSet.Remove
	 * @Covers TArray.Remove
	 * @Inputs Values [10, 20, 30] with Ids [10, 20, 30]; Remove 20
	 * @Return true when both tables drop 20
	 */
	UFUNCTION()
	bool SidecarRemoveKeepsIdsAligned()
	{
		TSet<int> Values;
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
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
			&& !Ids.Contains(20);
	}

	/**
	 * In-only: C++ passes aligned leftovers.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Remaining set as const TSet<int>&in
	 * @Param Ids Remaining ids as const TArray<int>&in
	 * @Inputs Values has 10 and 30; Ids is [10, 30]
	 * @Return true when lengths match and 10/30 are present
	 */
	UFUNCTION()
	bool ReadSidecarAligned(const TSet<int>&in Values, const TArray<int>&in Ids)
	{
		return Values.Num() == Ids.Num()
			&& Values.Num() == 2
			&& Values.Contains(10) && Values.Contains(30)
			&& Ids.Contains(10) && Ids.Contains(30);
	}

	/**
	 * Inout: Remove member 20 from both tables.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Set received as TSet<int>&inout
	 * @Param Ids Ids received as TArray<int>&inout
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return void; 20 is gone from both
	 */
	UFUNCTION()
	void RemoveSidecarMiddle(TSet<int>&inout Values, TArray<int>&inout Ids)
	{
		Values.Remove(20);
		Ids.Remove(20);
	}

	/**
	 * Confirm a sidecar id is still a set member. C++ checks the returned int.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Contains
	 * @Param Values Set as const TSet<int>&in
	 * @Param Ids Ids as const TArray<int>&in
	 * @Param Id Member to find
	 * @Inputs Aligned tables; Id present or missing
	 * @Return Id when present in both, or -1 when missing or lengths differ
	 */
	UFUNCTION()
	int LookupSidecarMember(const TSet<int>&in Values, const TArray<int>&in Ids, int Id)
	{
		if (Values.Num() != Ids.Num() || !Ids.Contains(Id) || !Values.Contains(Id))
		{
			return -1;
		}

		return Id;
	}

	/**
	 * Copy both tables, Remove 20, return remaining set for C++.
	 *
	 * @Kind RoundTrip
	 * @Covers TSet.Remove
	 * @Param Values Source set as const TSet<int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return TSet without 20
	 */
	UFUNCTION()
	TSet<int> ReturnValuesAfterSidecarRemove(const TSet<int>&in Values, const TArray<int>&in Ids)
	{
		TSet<int> OutValues;
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
	 * @Param Values Source set as const TSet<int>&in
	 * @Param Ids Source ids as const TArray<int>&in
	 * @Inputs Values has 10/20/30; Ids is [10, 20, 30]
	 * @Return TArray without 20
	 */
	UFUNCTION()
	TArray<int> ReturnIdsAfterSidecarRemove(const TSet<int>&in Values, const TArray<int>&in Ids)
	{
		TSet<int> OutValues;
		OutValues = Values;
		TArray<int> OutIds;
		OutIds = Ids;
		OutValues.Remove(20);
		OutIds.Remove(20);
		return OutIds;
	}
}
