/**
 * @version v1
 * @summary Proceed after the last element throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorProceedPastEnd
 */
/**
 * @begin IteratorProceedPastEnd
 * @summary Proceed after the last element throws Iterator out of bounds.
 * @topic Containers
 */
int IteratorProceedPastEnd()
{
	TArray<int32> Values;
	Values.Add(10);
	TArrayIterator<int32> It = Values.Iterator();
	It.Proceed();
	return It.Proceed();
}
/** @end */
