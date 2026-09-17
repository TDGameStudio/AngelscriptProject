/**
 * @version v1
 * @summary Observe TSet Add/Append/Remove/Empty/Reset, including duplicate Add and missing Remove.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSet Add/Append/Remove/Empty/Reset, including duplicate Add and missing Remove.
 * @topic Baseline
 */
// void TSet<T>.Append(const TArray<T>& Array);
// void TSet<T>.Append(const TSet<T>& Set);
// bool TSet<T>.Remove(const T& Value);
// void TSet<T>.Empty(int32 Slack = 0); void TSet<T>.Reset();
// Inputs: Seeded {1}, array {2, 3, 2}, other set {3, 4}, Remove 1 then
// missing 9, Empty and Empty(4), Reset.
// Expected observations: Add grows Num for new values only. Append from
// array and set unions membership. Remove returns true then false. Empty
// and Reset yield Num 0.
// Boundary/ownership: Append copies source elements; the source array/set
// remain. Empty with Slack may retain allocation.

namespace TS_TSet_MutationAndLifecycle_01
{
	bool Observe_Add_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		Set.Add(1);
		return Set.Num() == 2 && Set.Contains(1) && Set.Contains(2);
	}

	bool Observe_Append_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		TArray<int32> Array;
		Array.Add(2);
		Array.Add(3);
		Array.Add(2);
		Set.Append(Array);

		TSet<int32> Other;
		Other.Add(3);
		Other.Add(4);
		Set.Append(Other);

		return Set.Num() == 4 &&
			Set.Contains(2) &&
			Set.Contains(3) &&
			Set.Contains(4) &&
			Array.Num() == 3 &&
			Other.Num() == 2;
	}

	bool Observe_Remove_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		bool bRemoved = Set.Remove(1);
		bool bMissing = Set.Remove(9);
		return bRemoved && !bMissing && Set.Num() == 1 && Set.Contains(2);
	}

	bool Observe_Empty_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Empty();
		bool bDefaultEmpty = Set.IsEmpty();
		Set.Add(1);
		Set.Empty(4);
		return bDefaultEmpty && Set.IsEmpty();
	}

	bool Observe_Reset_Nominal()
	{
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		Set.Reset();
		return Set.IsEmpty() && Set.Num() == 0;
	}
}
/** @end */
