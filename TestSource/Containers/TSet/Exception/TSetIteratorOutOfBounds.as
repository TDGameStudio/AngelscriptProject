/**
 * Iterator.Proceed throws when there is no current element. Guard with
 * CanProceed in Function Observe; these entries skip that guard.
 *
 * @Theme Containers.TSet
 * @Subject TSet.Iterator
 * @Harness RuntimeException
 * @Tag Containers.TSet.TSetIteratorOutOfBounds
 * @Namespace TSetTest
 */

namespace TSetTest
{
	/**
	 * Proceed on an empty set throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TSet.Iterator
	 * @Inputs Empty TSet<int>; Iterator(); Proceed()
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	int ProceedOnEmpty()
	{
		TSet<int> Values;
		TSetIterator<int> It = Values.Iterator();
		return It.Proceed();
	}

	/**
	 * Proceed after the last element throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TSet.Iterator
	 * @Inputs [10]; Iterator(); Proceed(); Proceed() again
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Proceed past end
	 */
	UFUNCTION()
	int ProceedPastEnd()
	{
		TSet<int> Values;
		Values.Add(10);
		TSetIterator<int> It = Values.Iterator();
		It.Proceed();
		return It.Proceed();
	}
}
