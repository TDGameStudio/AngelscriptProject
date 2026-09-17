/**
 * @version v1
 * @summary A const&in TArray<bool> reports Shuffle membership.
 * @topic Containers
 *
 * ReadShufflePreservesMembershipBool
 */
/**
 * @begin ReadShufflePreservesMembershipBool
 * @summary A const&in TArray<bool> reports Shuffle membership.
 * @topic Containers
 */
bool ReadShufflePreservesMembershipBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
