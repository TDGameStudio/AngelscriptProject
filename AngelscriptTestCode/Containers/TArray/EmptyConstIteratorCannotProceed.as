/**
 * @version v1
 * @summary An empty const iterator cannot Proceed; a two-element const iterator proceeds twice.
 * @topic Containers
 *
 * EmptyConstIteratorCannotProceed
 */
/**
 * @begin EmptyConstIteratorCannotProceed
 * @summary An empty const iterator cannot Proceed; a two-element const iterator proceeds twice.
 * @topic Containers
 */
bool EmptyConstIteratorCannotProceed()
{
	TArray<int32> Empty;
	const TArray<int32> ConstEmpty = Empty;
	TArrayConstIterator<int32> EmptyIt = ConstEmpty.Iterator();
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	const TArray<int32> ConstValues = Values;
	TArrayConstIterator<int32> ConstIterator = ConstValues.Iterator();
	bool bPopulatedCanProceed = ConstIterator.CanProceed;
	ConstIterator.Proceed();
	bool bMidCanProceed = ConstIterator.CanProceed;
	ConstIterator.Proceed();
	return !EmptyIt.CanProceed && bPopulatedCanProceed && bMidCanProceed && !ConstIterator.CanProceed;
}
/** @end */
