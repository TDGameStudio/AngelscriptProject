/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports the overwritten Add value.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValueFName
 */
/**
 * @begin ReadAddOverwriteReplacesValueFName
 * @summary A const&in TMap<FName, int> reports the overwritten Add value.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValueFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains(n"Red") && Values[n"Red"] == 9;
}
/** @end */
