/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPairFName
 */
/**
 * @begin ReadRemoveKeyDropsPairFName
 * @summary A const&in TMap<FName, int> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPairFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 2 && Values.Contains(n"Red") && Values.Contains(n"Blue") && !Values.Contains(n"Green");
}
/** @end */
