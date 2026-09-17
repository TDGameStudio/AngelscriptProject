/**
 * @version v1
 * @summary Proceed on an empty iterator throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorOutOfBounds
 */
/**
 * @begin IteratorOutOfBounds
 * @summary Proceed on an empty iterator throws Iterator out of bounds.
 * @topic Containers
 */
void IteratorOutOfBounds()
{
	TMap<int, int> Values;
	TMapIterator<int, int> It = Values.Iterator();
	It.Proceed();
}
/** @end */
