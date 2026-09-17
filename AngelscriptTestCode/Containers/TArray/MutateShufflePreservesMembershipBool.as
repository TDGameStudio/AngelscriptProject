/**
 * @version v1
 * @summary An &inout TArray<bool> receives Shuffle in place.
 * @topic Containers
 *
 * MutateShufflePreservesMembershipBool
 */
/**
 * @begin MutateShufflePreservesMembershipBool
 * @summary An &inout TArray<bool> receives Shuffle in place.
 * @topic Containers
 */
void MutateShufflePreservesMembershipBool(TArray<bool>&inout Values)
{
	Values.Shuffle();
}
/** @end */
