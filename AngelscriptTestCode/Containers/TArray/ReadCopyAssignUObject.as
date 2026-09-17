/**
 * @version v1
 * @summary A const&in TArray<UObject> reports assigned handle count and identity.
 * @topic Containers
 *
 * ReadCopyAssignUObject
 */
/**
 * @begin ReadCopyAssignUObject
 * @summary A const&in TArray<UObject> reports assigned handle count and identity.
 * @topic Containers
 */
bool ReadCopyAssignUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 2 && Values[0] != nullptr && Values[1] != nullptr && Values[0] != Values[1];
}
/** @end */
