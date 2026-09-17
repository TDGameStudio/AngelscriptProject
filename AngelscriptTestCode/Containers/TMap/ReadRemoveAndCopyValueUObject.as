/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValueUObject
 */
/**
 * @begin ReadRemoveAndCopyValueUObject
 * @summary A const&in TMap<int, UObject> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValueUObject(const TMap<int, UObject>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
