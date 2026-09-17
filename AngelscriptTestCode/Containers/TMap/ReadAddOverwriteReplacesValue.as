/**
 * @version v1
 * @summary A const&in TMap<int, int> reports the overwritten Add value.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValue
 */
/**
 * @begin ReadAddOverwriteReplacesValue
 * @summary A const&in TMap<int, int> reports the overwritten Add value.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValue(const TMap<int, int>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10) && Values[10] == 999;
}
/** @end */
