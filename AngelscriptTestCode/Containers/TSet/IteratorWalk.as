/**
 * @version v1
 * @summary Iterator() reports CanProceed on a populated set and not on an empty set.
 * @topic Containers
 *
 * IteratorWalk
 */
/**
 * @begin IteratorWalk
 * @summary Iterator() reports CanProceed on a populated set and not on an empty set.
 * @topic Containers
 */
bool IteratorWalk()
{
	TSet<int32> Empty;
	TSetIterator<int32> EmptyIt = Empty.Iterator();
	TSet<int32> Values;
	Values.Add(1);
	TSetIterator<int32> It = Values.Iterator();
	return !EmptyIt.CanProceed && It.CanProceed;
}
/** @end */
