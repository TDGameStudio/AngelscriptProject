/**
 * @version v1
 * @summary Observe TSet copy assignment independence and iterator assignment for mutable and const iterators.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TSet copy assignment independence and iterator assignment for mutable and const iterators.
 * @topic Baseline
 */
// iterators from the copied set.
// Expected observations: Copy assignment copies Num and membership. Add on
// Other after copy does not appear in Set. Assigned iterators CanProceed on
// a populated set.
// Boundary/ownership: Assignment copies elements. Iterators alias the
// destination set.

namespace TS_TSet_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		TSet<int32> Other;
		Other.Add(1);
		Other.Add(2);
		TSet<int32> Set;
		Set = Other;
		Other.Add(3);

		TSet<FName> NameOther;
		NameOther.Add(n"Alpha");
		TSet<FName> NameSet;
		NameSet = NameOther;

		TSetIterator<int32> It;
		TSetIterator<int32> OtherIt = Set.Iterator();
		It = OtherIt;

		const TSet<int32> ConstSet = Set;
		TSetConstIterator<int32> ConstIt;
		TSetConstIterator<int32> ConstOtherIt = ConstSet.Iterator();
		ConstIt = ConstOtherIt;

		return Set.Num() == 2 &&
			Set.Contains(1) &&
			Set.Contains(2) &&
			!Set.Contains(3) &&
			Other.Num() == 3 &&
			NameSet.Contains(n"Alpha") &&
			NameSet.Num() == 1 &&
			It.CanProceed &&
			OtherIt.CanProceed &&
			ConstIt.CanProceed &&
			ConstOtherIt.CanProceed;
	}
}
/** @end */
