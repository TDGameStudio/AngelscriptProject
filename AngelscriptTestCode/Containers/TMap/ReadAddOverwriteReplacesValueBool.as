/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports the overwritten Add value.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValueBool
 */
/**
 * @begin ReadAddOverwriteReplacesValueBool
 * @summary A const&in TMap<int, bool> reports the overwritten Add value.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValueBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 1 && Values.Contains(1) && Values[1] == false;
}
/** @end */
