/**
 * @version v1
 * @summary Copy-constructed TSetIterator preserves CanProceed on a populated set.
 * @topic Containers
 *
 * CopyConstructedIteratorPreserves
 */
/**
 * @begin CopyConstructedIteratorPreserves
 * @summary Copy-constructed TSetIterator preserves CanProceed on a populated set.
 * @topic Containers
 */
bool CopyConstructedIteratorPreserves()
{
	TSet<int32> Values;
	Values.Add(1);
	TSetIterator<int32> Other = Values.Iterator();
	TSetIterator<int32> It(Other);
	return It.CanProceed && Other.CanProceed;
}
/** @end */
