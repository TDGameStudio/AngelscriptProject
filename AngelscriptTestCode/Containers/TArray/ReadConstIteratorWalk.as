/**
 * @version v1
 * @summary A const&in TArray<int32> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalk
 */
/**
 * @begin ReadConstIteratorWalk
 * @summary A const&in TArray<int32> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalk(const TArray<int32>&in Values)
{
	TArrayConstIterator<int32> ConstIterator = Values.Iterator();
	const int32& First = ConstIterator.Proceed();
	const int32& Second = ConstIterator.Proceed();
	const int32& Third = ConstIterator.Proceed();
	return First == 1 && Second == 2 && Third == 3 && !ConstIterator.CanProceed;
}
/** @end */
