/**
 * @version v1
 * @summary A const&in TMap<int, int> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPair
 */
/**
 * @begin ReadRemoveKeyDropsPair
 * @summary A const&in TMap<int, int> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPair(const TMap<int, int>&in Values)
{
	return Values.Num() == 2 && Values.Contains(10) && Values.Contains(30) && !Values.Contains(20);
}
/** @end */
