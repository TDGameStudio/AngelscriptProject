/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports the overwritten Add value.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValueFString
 */
/**
 * @begin ReadAddOverwriteReplacesValueFString
 * @summary A const&in TMap<FString, int> reports the overwritten Add value.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValueFString(const TMap<FString, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains("alpha") && Values["alpha"] == 999;
}
/** @end */
