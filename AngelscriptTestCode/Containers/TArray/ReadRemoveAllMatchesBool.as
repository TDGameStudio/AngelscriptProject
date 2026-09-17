/**
 * @version v1
 * @summary A const&in TArray<bool> reports the array after Remove deleted every match.
 * @topic Containers
 *
 * ReadRemoveAllMatchesBool
 */
/**
 * @begin ReadRemoveAllMatchesBool
 * @summary A const&in TArray<bool> reports the array after Remove deleted every match.
 * @topic Containers
 */
bool ReadRemoveAllMatchesBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && Values[0] == false && Values[1] == false;
}
/** @end */
