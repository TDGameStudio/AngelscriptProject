/**
 * @version v1
 * @summary A const&in TMap<FString, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValueFString
 */
/**
 * @begin ReadRemoveAndCopyValueFString
 * @summary A const&in TMap<FString, int> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValueFString(const TMap<FString, int>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
