/**
 * @version v1
 * @summary An empty mutable iterator cannot Proceed; a populated one can until it is exhausted.
 * @topic Containers
 *
 * EmptyIteratorCannotProceed
 */
/**
 * @begin EmptyIteratorCannotProceed
 * @summary An empty mutable iterator cannot Proceed; a populated one can until it is exhausted.
 * @topic Containers
 */
bool EmptyIteratorCannotProceed()
{
	TArray<int32> Empty;
	TArrayIterator<int32> EmptyIt = Empty.Iterator();
	TArray<int32> Values;
	Values.Add(1);
	TArrayIterator<int32> Iterator = Values.Iterator();
	bool bPopulatedCanProceed = Iterator.CanProceed;
	Iterator.Proceed();
	return !EmptyIt.CanProceed && bPopulatedCanProceed && !Iterator.CanProceed;
}
/** @end */
