/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValueFName
 */
/**
 * @begin ReadRemoveAndCopyValueFName
 * @summary A const&in TMap<FName, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValueFName(const TMap<FName, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
