/**
 * @version v1
 * @summary Mutable TMapIterator on a populated map CanProceed.
 * @topic Containers
 *
 * MutableIteratorPopulated
 */
/**
 * @begin MutableIteratorPopulated
 * @summary Mutable TMapIterator on a populated map CanProceed.
 * @topic Containers
 */
bool MutableIteratorPopulated()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	return It.CanProceed;
}
/** @end */
