/**
 * @version v1
 * @summary Copy-constructed const iterator preserves CanProceed.
 * @topic Containers
 *
 * CopyConstructedConstIterator
 */
/**
 * @begin CopyConstructedConstIterator
 * @summary Copy-constructed const iterator preserves CanProceed.
 * @topic Containers
 */
bool CopyConstructedConstIterator()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> Other = ConstMap.Iterator();
	TMapConstIterator<FName, int32> It(Other);
	TMap<FName, int32> Empty;
	const TMap<FName, int32> ConstEmpty = Empty;
	TMapConstIterator<FName, int32> EmptyIt = ConstEmpty.Iterator();
	return It.CanProceed && !EmptyIt.CanProceed;
}
/** @end */
