/**
 * @version v1
 * @summary RemoveAt(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 *
 * RemoveAtOutOfBounds
 */
/**
 * @begin RemoveAtOutOfBounds
 * @summary RemoveAt(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 */
void RemoveAtOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.RemoveAt(1);
}
/** @end */
