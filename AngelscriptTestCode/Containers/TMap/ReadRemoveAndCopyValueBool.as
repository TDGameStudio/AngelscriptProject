/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValueBool
 */
/**
 * @begin ReadRemoveAndCopyValueBool
 * @summary A const&in TMap<int, bool> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValueBool(const TMap<int, bool>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
