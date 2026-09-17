/**
 * @version v1
 * @summary Read [0] on an empty array throws Array index out of bounds.
 * @topic Containers
 *
 * EmptyIndex
 */
/**
 * @begin EmptyIndex
 * @summary Read [0] on an empty array throws Array index out of bounds.
 * @topic Containers
 */
int EmptyIndex()
{
	TArray<int32> Values;
	return Values[0];
}
/** @end */
