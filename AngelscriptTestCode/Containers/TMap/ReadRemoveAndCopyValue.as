/**
 * @version v1
 * @summary A const&in TMap<int, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValue
 */
/**
 * @begin ReadRemoveAndCopyValue
 * @summary A const&in TMap<int, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValue(const TMap<int, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
