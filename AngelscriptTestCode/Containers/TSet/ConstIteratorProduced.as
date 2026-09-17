/**
 * @version v1
 * @summary Iterator() on a const populated set produces a TSetConstIterator that can proceed.
 * @topic Containers
 *
 * ConstIteratorProduced
 */
/**
 * @begin ConstIteratorProduced
 * @summary Iterator() on a const populated set produces a TSetConstIterator that can proceed.
 * @topic Containers
 */
bool ConstIteratorProduced()
{
	TSet<int32> Values;
	Values.Add(1);
	const TSet<int32> ConstValues = Values;
	TSetConstIterator<int32> It = ConstValues.Iterator();
	return It.CanProceed;
}
/** @end */
