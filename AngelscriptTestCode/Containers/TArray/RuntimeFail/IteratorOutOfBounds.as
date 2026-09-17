/**
 * @version v1
 * @summary Iterator.Proceed on an empty array throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorOutOfBounds
 */
/**
 * @begin IteratorOutOfBounds
 * @summary Iterator.Proceed on an empty array throws Iterator out of bounds.
 * @topic Containers
 */
int IteratorOutOfBounds()
{
	TArray<int32> Values;
	TArrayIterator<int32> It = Values.Iterator();
	return It.Proceed();
}
/** @end */
