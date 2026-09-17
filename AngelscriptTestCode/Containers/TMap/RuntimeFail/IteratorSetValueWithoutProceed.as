/**
 * @version v1
 * @summary SetValue before Proceed throws Iterator out of bounds.
 * @topic Containers
 *
 * IteratorSetValueWithoutProceed
 */
/**
 * @begin IteratorSetValueWithoutProceed
 * @summary SetValue before Proceed throws Iterator out of bounds.
 * @topic Containers
 */
void IteratorSetValueWithoutProceed()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.SetValue(8);
}
/** @end */
