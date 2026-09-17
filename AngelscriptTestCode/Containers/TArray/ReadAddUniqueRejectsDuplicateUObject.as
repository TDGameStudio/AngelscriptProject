/**
 * @version v1
 * @summary A const&in TArray<UObject> reports unique AddUnique order by identity.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicateUObject
 */
/**
 * @begin ReadAddUniqueRejectsDuplicateUObject
 * @summary A const&in TArray<UObject> reports unique AddUnique order by identity.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicateUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr
		&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
}
/** @end */
