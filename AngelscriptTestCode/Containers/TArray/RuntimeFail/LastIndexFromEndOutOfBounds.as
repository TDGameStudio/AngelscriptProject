/**
 * @version v1
 * @summary Last(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 *
 * LastIndexFromEndOutOfBounds
 */
/**
 * @begin LastIndexFromEndOutOfBounds
 * @summary Last(1) on a one-element array throws Array index out of bounds.
 * @topic Containers
 */
int LastIndexFromEndOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	return Values.Last(1);
}
/** @end */
