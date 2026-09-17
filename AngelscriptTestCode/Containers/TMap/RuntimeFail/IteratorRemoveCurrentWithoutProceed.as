/**
 * @version v1
 * @summary RemoveCurrent before Proceed throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorRemoveCurrentWithoutProceed
 */
/**
 * @begin IteratorRemoveCurrentWithoutProceed
 * @summary RemoveCurrent before Proceed throws Iterator out of bounds.
 * @topic Containers
 */
void IteratorRemoveCurrentWithoutProceed()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.RemoveCurrent();
}
/** @end */
