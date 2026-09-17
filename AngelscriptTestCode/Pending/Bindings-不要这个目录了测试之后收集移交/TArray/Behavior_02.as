/**
 * @version v1
 * @summary Observe TArrayConstIterator.CanProceed on empty, populated, and exhausted const iterators. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TArrayConstIterator.CanProceed on empty, populated, and exhausted const iterators. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// both Proceed calls.
// Expected observations: Empty const iterator CanProceed is false. Populated
// starts true. After visiting both elements CanProceed is false.
// Boundary/ownership: CanProceed is a property on the iterator, not a method.
// The const iterator does not mutate the array.

namespace TS_TArray_Behavior_02
{
	// Empty const iterator CannotProceed; populated is true, mid true, then false.
	bool Observe_Surface047_Nominal()
	{
		TArray<int32> Empty;
		const TArray<int32> ConstEmpty = Empty;
		TArrayConstIterator<int32> EmptyIt = ConstEmpty.Iterator();
		TArray<int32> Array;
		Array.Add(1);
		Array.Add(2);
		const TArray<int32> ConstArray = Array;
		TArrayConstIterator<int32> ConstIterator = ConstArray.Iterator();
		bool bPopulatedCanProceed = ConstIterator.CanProceed;
		ConstIterator.Proceed();
		bool bMidCanProceed = ConstIterator.CanProceed;
		ConstIterator.Proceed();
		return !EmptyIt.CanProceed && bPopulatedCanProceed && bMidCanProceed && !ConstIterator.CanProceed;
	}
}
/** @end */
