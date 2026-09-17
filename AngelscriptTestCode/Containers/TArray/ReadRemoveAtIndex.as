/**
 * @version v1
 * @summary A const&in TArray<int32> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 *
 * ReadRemoveAtIndex
 */
/**
 * @begin ReadRemoveAtIndex
 * @summary A const&in TArray<int32> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 */
bool ReadRemoveAtIndex(const TArray<int32>&in Values)
{
	return Values.Num() == 2 && Values[0] == 2 && Values[1] == 3;
}
/** @end */
