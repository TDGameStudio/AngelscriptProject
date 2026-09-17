/**
 * @version v1
 * @summary Observe TSet Contains, Num, and IsEmpty on empty and populated sets, including duplicate Add.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSet Contains, Num, and IsEmpty on empty and populated sets, including duplicate Add.
 * @topic Baseline
 */
// int32 TSet<T>.Num() const; bool TSet<T>.IsEmpty() const;
// Inputs: Default-empty set, {1, 2} with a duplicate Add(1), lookup 2 and
// missing 9, and a TSet<FName> containing n"Alpha".
// Expected observations: Empty Contains/Num/IsEmpty are false/0/true.
// Duplicate Add does not grow Num. Contains 2 is true and 9 is false.
// Boundary/ownership: Queries do not mutate. Membership uses element
// equality, not insertion identity.

namespace TS_TSet_Queries_01
{
	bool Observe_Contains_Nominal()
	{
		TSet<int32> Empty;
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		TSet<FName> Names;
		Names.Add(n"Alpha");
		return !Empty.Contains(1) && Set.Contains(2) && !Set.Contains(9) && Names.Contains(n"Alpha");
	}

	bool Observe_Num_Nominal()
	{
		TSet<int32> Empty;
		TSet<int32> Set;
		Set.Add(1);
		Set.Add(2);
		Set.Add(1);
		return Empty.Num() == 0 && Set.Num() == 2;
	}

	bool Observe_IsEmpty_Nominal()
	{
		TSet<int32> Empty;
		TSet<int32> Set;
		Set.Add(1);
		return Empty.IsEmpty() && !Set.IsEmpty();
	}
}
/** @end */
