/**
 * @version v1
 * @summary RemoveAt drops the indexed element and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndex
 */
/**
 * @begin RemoveAtIndex
 * @summary RemoveAt drops the indexed element and shifts later elements down.
 * @topic Containers
 */
bool RemoveAtIndex()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	Values.RemoveAt(1);
	return Values.Num() == 2 && Values[0] == 1 && Values[1] == 3;
}
/** @end */
