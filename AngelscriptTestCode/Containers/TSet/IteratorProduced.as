/**
 * @version v1
 * @summary Iterator() on a populated set produces a TSetIterator that can proceed.
 * @topic Containers
 *
 * IteratorProduced
 */
/**
 * @begin IteratorProduced
 * @summary Iterator() on a populated set produces a TSetIterator that can proceed.
 * @topic Containers
 */
bool IteratorProduced()
{
	TSet<int32> Values;
	Values.Add(1);
	TSetIterator<int32> It = Values.Iterator();
	return It.CanProceed;
}
/** @end */
