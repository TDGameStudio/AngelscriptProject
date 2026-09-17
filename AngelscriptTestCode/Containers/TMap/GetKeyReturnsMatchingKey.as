/**
 * @version v1
 * @summary Iterator GetKey after Proceed returns the current key.
 * @topic Containers
 *
 * GetKeyReturnsMatchingKey
 */
/**
 * @begin GetKeyReturnsMatchingKey
 * @summary Iterator GetKey after Proceed returns the current key.
 * @topic Containers
 */
bool GetKeyReturnsMatchingKey()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.Proceed();
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
	ConstIt.Proceed();
	return It.GetKey() == n"Alpha" && ConstIt.GetKey() == n"Alpha";
}
/** @end */
