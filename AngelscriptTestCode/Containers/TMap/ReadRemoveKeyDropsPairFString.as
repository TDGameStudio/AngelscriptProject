/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPairFString
 */
/**
 * @begin ReadRemoveKeyDropsPairFString
 * @summary A const&in TMap<FString, int> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPairFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 2 && Values.Contains("alpha") && Values.Contains("gamma") && !Values.Contains("beta");
}
/** @end */
