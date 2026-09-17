/**
 * @version v1
 * @summary Read [1] on a one-element array throws Array index out of bounds.
 * @topic Containers
 *
 * IndexOutOfBounds
 */
/**
 * @begin IndexOutOfBounds
 * @summary Read [1] on a one-element array throws Array index out of bounds.
 * @topic Containers
 */
int IndexOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	return Values[1];
}
/** @end */
