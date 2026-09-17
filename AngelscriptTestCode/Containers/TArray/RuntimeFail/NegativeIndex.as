/**
 * @version v1
 * @summary Read [-1] throws Array index out of bounds.
 * @topic Containers
 *
 * NegativeIndex
 */
/**
 * @begin NegativeIndex
 * @summary Read [-1] throws Array index out of bounds.
 * @topic Containers
 */
int NegativeIndex()
{
	TArray<int32> Values;
	Values.Add(10);
	return Values[-1];
}
/** @end */
