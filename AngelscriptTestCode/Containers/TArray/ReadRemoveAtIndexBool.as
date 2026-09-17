/**
 * @version v1
 * @summary A const&in TArray<bool> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 *
 * ReadRemoveAtIndexBool
 */
/**
 * @begin ReadRemoveAtIndexBool
 * @summary A const&in TArray<bool> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 */
bool ReadRemoveAtIndexBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && Values[0] == false && Values[1] == true;
}
/** @end */
