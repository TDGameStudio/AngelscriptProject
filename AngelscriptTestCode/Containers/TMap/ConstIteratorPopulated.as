/**
 * @version v1
 * @summary Const TMapConstIterator on a populated map CanProceed.
 * @topic Containers
 *
 * ConstIteratorPopulated
 */
/**
 * @begin ConstIteratorPopulated
 * @summary Const TMapConstIterator on a populated map CanProceed.
 * @topic Containers
 */
bool ConstIteratorPopulated()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> It = ConstMap.Iterator();
	return It.CanProceed;
}
/** @end */
