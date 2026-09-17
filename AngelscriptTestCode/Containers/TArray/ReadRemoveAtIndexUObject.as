/**
 * @version v1
 * @summary A const&in TArray<UObject> reports the array after RemoveAt shifted later handles.
 * @topic Containers
 *
 * ReadRemoveAtIndexUObject
 */
/**
 * @begin ReadRemoveAtIndexUObject
 * @summary A const&in TArray<UObject> reports the array after RemoveAt shifted later handles.
 * @topic Containers
 */
bool ReadRemoveAtIndexUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 2 && Values[0] != nullptr && Values[1] != nullptr;
}
/** @end */
