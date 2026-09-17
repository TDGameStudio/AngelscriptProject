/**
 * @version v1
 * @summary Empty mutable iterator CannotProceed.
 * @topic Containers
 *
 * EmptyMutableIteratorCannotProceed
 */
/**
 * @begin EmptyMutableIteratorCannotProceed
 * @summary Empty mutable iterator CannotProceed.
 * @topic Containers
 */
bool EmptyMutableIteratorCannotProceed()
{
	TMap<FName, int32> Empty;
	TMapIterator<FName, int32> EmptyIt = Empty.Iterator();
	return !EmptyIt.CanProceed;
}
/** @end */
