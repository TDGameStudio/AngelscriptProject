/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPairBool
 */
/**
 * @begin ReadRemoveKeyDropsPairBool
 * @summary A const&in TMap<int, bool> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPairBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 2 && Values.Contains(1) && Values.Contains(3) && !Values.Contains(2);
}
/** @end */
