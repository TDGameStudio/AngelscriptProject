/**
 * @version v1
 * @summary RemoveAtSwap(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 *
 * RemoveAtSwapOutOfBounds
 */
/**
 * @begin RemoveAtSwapOutOfBounds
 * @summary RemoveAtSwap(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 */
void RemoveAtSwapOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.RemoveAtSwap(1);
}
/** @end */
