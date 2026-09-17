/**
 * @version v1
 * @summary Copy-constructed TSetConstIterator preserves CanProceed on a populated set.
 * @topic Containers
 *
 * CopyConstructedConstIterator
 */
/**
 * @begin CopyConstructedConstIterator
 * @summary Copy-constructed TSetConstIterator preserves CanProceed on a populated set.
 * @topic Containers
 */
bool CopyConstructedConstIterator()
{
	TSet<int32> Values;
	Values.Add(1);
	const TSet<int32> ConstValues = Values;
	TSetConstIterator<int32> Other = ConstValues.Iterator();
	TSetConstIterator<int32> It(Other);
	return It.CanProceed;
}
/** @end */
