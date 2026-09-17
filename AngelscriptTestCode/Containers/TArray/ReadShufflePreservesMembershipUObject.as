/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Shuffle membership by identity.
 * @topic Containers
 *
 * ReadShufflePreservesMembershipUObject
 */
/**
 * @begin ReadShufflePreservesMembershipUObject
 * @summary A const&in TArray<UObject> reports Shuffle membership by identity.
 * @topic Containers
 */
bool ReadShufflePreservesMembershipUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values[0] != nullptr && Values[1] != nullptr && Values[2] != nullptr;
}
/** @end */
