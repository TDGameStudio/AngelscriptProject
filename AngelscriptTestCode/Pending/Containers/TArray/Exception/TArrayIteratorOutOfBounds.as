/**
 * @version v1
 * @summary Iterator.Proceed throws when there is no current element. Guard with CanProceed in Function Observe; these entries skip that guard.
 * @topic Containers
 */
/**
 * @version root
 * @summary Iterator.Proceed throws when there is no current element. Guard with CanProceed in Function Observe; these entries skip that guard.
 * @topic Baseline
 */
namespace TArrayTest
{
	/**
	 * Proceed on an empty array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Iterator
	 * @Inputs Empty TArray<int>; Iterator(); Proceed()
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	int ProceedOnEmpty()
	{
		TArray<int> Values;
		TArrayIterator<int> It = Values.Iterator();
		return It.Proceed();
	}

	/**
	 * Proceed after the last element throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.Iterator
	 * @Inputs [10]; Iterator(); Proceed(); Proceed() again
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Proceed past end
	 */
	UFUNCTION()
	int ProceedPastEnd()
	{
		TArray<int> Values;
		Values.Add(10);
		TArrayIterator<int> It = Values.Iterator();
		It.Proceed();
		return It.Proceed();
	}
}
/** @end */
