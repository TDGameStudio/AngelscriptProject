/**
 * @version v1
 * @summary Write [-1] throws Array index out of bounds.
 * @topic Containers
 *
 * WriteNegativeIndex
 */
/**
 * @begin WriteNegativeIndex
 * @summary Write [-1] throws Array index out of bounds.
 * @topic Containers
 */
void WriteNegativeIndex()
{
	TArray<int32> Values;
	Values.Add(10);
	Values[-1] = 20;
}
/** @end */
