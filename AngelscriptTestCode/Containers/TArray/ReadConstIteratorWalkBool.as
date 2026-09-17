/**
 * @version v1
 * @summary A const&in TArray<bool> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalkBool
 */
/**
 * @begin ReadConstIteratorWalkBool
 * @summary A const&in TArray<bool> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalkBool(const TArray<bool>&in Values)
{
	TArrayConstIterator<bool> ConstIterator = Values.Iterator();
	const bool& First = ConstIterator.Proceed();
	const bool& Second = ConstIterator.Proceed();
	return First == false && Second == true && !ConstIterator.CanProceed;
}
/** @end */
