/**
 * @version v1
 * @summary Empty iterator cannot proceed; a populated iterator can.
 * @topic Containers
 *
 * IteratorWalk
 */
/**
 * @begin IteratorWalk
 * @summary Empty iterator cannot proceed; a populated iterator can.
 * @topic Containers
 */
bool IteratorWalk()
{
	TMap<FName, int32> Empty;
	TMapIterator<FName, int32> EmptyIt = Empty.Iterator();
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
	return !EmptyIt.CanProceed && It.CanProceed && ConstIt.CanProceed;
}
/** @end */
