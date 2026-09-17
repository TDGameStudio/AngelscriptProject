/**
 * @version v1
 * @summary A const&in TMap<int, UObject> reports assigned pairs.
 * @topic Containers
 *
 * ReadCopyAssignUObject
 */
/**
 * @begin ReadCopyAssignUObject
 * @summary A const&in TMap<int, UObject> reports assigned pairs.
 * @topic Containers
 */
bool ReadCopyAssignUObject(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(10) && Values.Contains(20) && Values.Contains(30)
		&& Values[10] != nullptr && Values[20] != nullptr && Values[30] != nullptr;
}
/** @end */
