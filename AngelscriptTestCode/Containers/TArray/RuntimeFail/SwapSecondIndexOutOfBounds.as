/**
 * @version v1
 * @summary Swap whose second index is past Num throws Array index out of bounds.
 * @topic Containers
 *
 * SwapSecondIndexOutOfBounds
 */
/**
 * @begin SwapSecondIndexOutOfBounds
 * @summary Swap whose second index is past Num throws Array index out of bounds.
 * @topic Containers
 */
void SwapSecondIndexOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Swap(0, 2);
}
/** @end */
