/**
 * @version v1
 * @summary GetKey before Proceed throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorGetKeyWithoutProceed
 */
/**
 * @begin IteratorGetKeyWithoutProceed
 * @summary GetKey before Proceed throws Iterator out of bounds.
 * @topic Containers
 */
void IteratorGetKeyWithoutProceed()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	FName Key = It.GetKey();
}
/** @end */
