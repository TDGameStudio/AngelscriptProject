/**
 * @version v1
 * @summary A const&in TArray<UObject> reports the array after Remove deleted every match.
 * @topic Containers
 *
 * ReadRemoveAllMatchesUObject
 */
/**
 * @begin ReadRemoveAllMatchesUObject
 * @summary A const&in TArray<UObject> reports the array after Remove deleted every match.
 * @topic Containers
 */
bool ReadRemoveAllMatchesUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 4
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr && Values[3] != nullptr;
}
/** @end */
