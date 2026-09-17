/**
 * @version v1
 * @summary An empty-set iterator cannot proceed.
 * @topic Containers
 *
 * EmptyIteratorCannotProceed
 */
/**
 * @begin EmptyIteratorCannotProceed
 * @summary An empty-set iterator cannot proceed.
 * @topic Containers
 */
bool EmptyIteratorCannotProceed()
{
	TSet<int32> Empty;
	TSetIterator<int32> EmptyIt = Empty.Iterator();
	return !EmptyIt.CanProceed;
}
/** @end */
