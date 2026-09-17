/**
 * @version v1
 * @summary A const&in TArray<float> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalkFloat
 */
/**
 * @begin ReadConstIteratorWalkFloat
 * @summary A const&in TArray<float> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalkFloat(const TArray<float>&in Values)
{
	TArrayConstIterator<float> ConstIterator = Values.Iterator();
	const float& First = ConstIterator.Proceed();
	const float& Second = ConstIterator.Proceed();
	return First == 1.0f && Second == 2.0f && !ConstIterator.CanProceed;
}
/** @end */
