/**
 * @version v1
 * @summary An &inout TArray<int32> receives Shuffle in place.
 * @topic Containers
 *
 * MutateShufflePreservesMembership
 */
/**
 * @begin MutateShufflePreservesMembership
 * @summary An &inout TArray<int32> receives Shuffle in place.
 * @topic Containers
 */
void MutateShufflePreservesMembership(TArray<int32>&inout Values)
{
	Values.Shuffle();
}
/** @end */
