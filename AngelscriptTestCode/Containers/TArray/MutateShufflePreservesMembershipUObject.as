/**
 * @version v1
 * @summary An &inout TArray<UObject> receives Shuffle in place.
 * @topic Containers
 *
 * MutateShufflePreservesMembershipUObject
 */
/**
 * @begin MutateShufflePreservesMembershipUObject
 * @summary An &inout TArray<UObject> receives Shuffle in place.
 * @topic Containers
 */
void MutateShufflePreservesMembershipUObject(TArray<UObject>&inout Values)
{
	Values.Shuffle();
}
/** @end */
