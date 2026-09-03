/**
 * Iterator.Proceed / GetKey / GetValue / SetValue / RemoveCurrent throw when
 * there is no current element. Guard with CanProceed in Function Observe;
 * these entries skip that guard.
 *
 * @Theme Containers.TMap
 * @Subject TMap.Iterator
 * @Harness RuntimeException
 * @Tag Containers.TMap.TMapIteratorOutOfBounds
 * @Namespace TMapTest
 */

namespace TMapTest
{
	/**
	 * Proceed on an empty map throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs Empty TMap<int, int>; Iterator(); Proceed()
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Num() == 0
	 */
	UFUNCTION()
	void ProceedOnEmpty()
	{
		TMap<int, int> Values;
		TMapIterator<int, int> It = Values.Iterator();
		It.Proceed();
	}

	/**
	 * Proceed after the last pair throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs one pair; Iterator(); Proceed(); Proceed() again
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Proceed past end
	 */
	UFUNCTION()
	void ProceedPastEnd()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		TMapIterator<int, int> It = Values.Iterator();
		It.Proceed();
		It.Proceed();
	}

	/**
	 * GetKey before Proceed throws; Index starts at -1.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs one pair; Iterator(); GetKey() before Proceed
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Index == -1
	 */
	UFUNCTION()
	int GetKeyBeforeProceed()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		TMapIterator<int, int> It = Values.Iterator();
		return It.GetKey();
	}

	/**
	 * GetValue before Proceed throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs one pair; Iterator(); GetValue() before Proceed
	 * @Return does not return; throws "Iterator out of bounds."
	 * @Boundary Index == -1
	 */
	UFUNCTION()
	int GetValueBeforeProceed()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		TMapIterator<int, int> It = Values.Iterator();
		return It.GetValue();
	}

	/**
	 * SetValue before Proceed throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs one pair; Iterator(); SetValue before Proceed
	 * @Return void; throws "Iterator out of bounds."
	 * @Boundary Index == -1
	 */
	UFUNCTION()
	void SetValueBeforeProceed()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		TMapIterator<int, int> It = Values.Iterator();
		It.SetValue(7);
	}

	/**
	 * RemoveCurrent before Proceed throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TMap.Iterator
	 * @Inputs one pair; Iterator(); RemoveCurrent before Proceed
	 * @Return void; throws "Iterator out of bounds."
	 * @Boundary Index == -1
	 */
	UFUNCTION()
	void RemoveCurrentBeforeProceed()
	{
		TMap<int, int> Values;
		Values.Add(10, 100);
		TMapIterator<int, int> It = Values.Iterator();
		It.RemoveCurrent();
	}
}
