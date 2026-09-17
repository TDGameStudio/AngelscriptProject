/**
 * @version v1
 * @summary Swap with a negative first index throws Array index out of bounds.
 * @topic Containers
 *
 * SwapOutOfBounds
 */
/**
 * @begin SwapOutOfBounds
 * @summary Swap with a negative first index throws Array index out of bounds.
 * @topic Containers
 */
void SwapOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Swap(-1, 0);
}
/** @end */
