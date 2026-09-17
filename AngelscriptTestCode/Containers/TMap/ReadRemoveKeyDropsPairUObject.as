/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPairUObject
 */
/**
 * @begin ReadRemoveKeyDropsPairUObject
 * @summary A const&in TMap<int, UObject> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPairUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 2 && Values.Contains(10) && Values.Contains(30) && !Values.Contains(20);
}
/** @end */
