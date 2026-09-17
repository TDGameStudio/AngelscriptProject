/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports the overwritten Add handle.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValueUObject
 */
/**
 * @begin ReadAddOverwriteReplacesValueUObject
 * @summary A const&in TMap<int, UObject> reports the overwritten Add handle.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValueUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10) && Values[10] != nullptr;
}
/** @end */
