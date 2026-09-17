/**
 * @version v1
 * @summary Iterator RemoveCurrent after Proceed deletes the current pair.
 * @topic Containers
 *
 * RemoveCurrent
 */
/**
 * @begin RemoveCurrent
 * @summary Iterator RemoveCurrent after Proceed deletes the current pair.
 * @topic Containers
 */
bool RemoveCurrent()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.Proceed();
	FName RemovedKey = It.GetKey();
	It.RemoveCurrent();
	return Map.Num() == 1 && !Map.Contains(RemovedKey);
}
/** @end */
