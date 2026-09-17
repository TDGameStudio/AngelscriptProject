/**
 * @version v1
 * @summary Copy-constructed mutable iterator preserves CanProceed.
 * @topic Containers
 *
 * CopyConstructedMutableIterator
 */
/**
 * @begin CopyConstructedMutableIterator
 * @summary Copy-constructed mutable iterator preserves CanProceed.
 * @topic Containers
 */
bool CopyConstructedMutableIterator()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> Other = Map.Iterator();
	TMapIterator<FName, int32> It(Other);
	return It.CanProceed && Other.CanProceed;
}
/** @end */
