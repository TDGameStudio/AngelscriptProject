/**
 * @version v1
 * @summary Iterator.Proceed throws Iterator out of bounds. when there is no current element.
 * @topic Containers
 *
 * IteratorOutOfBounds
 */
/**
 * @begin IteratorOutOfBounds
 * @summary Iterator.Proceed throws Iterator out of bounds. when there is no current element.
 * @topic Containers
 */
int IteratorOutOfBounds()
{
	TSet<int> Values;
	TSetIterator<int> It = Values.Iterator();
	return It.Proceed();
}
/** @end */
