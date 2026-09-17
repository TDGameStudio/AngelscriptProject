/**
 * @version v1
 * @summary An &inout TArray<FString> receives Shuffle in place.
 * @topic Containers
 *
 * MutateShufflePreservesMembershipFString
 */
/**
 * @begin MutateShufflePreservesMembershipFString
 * @summary An &inout TArray<FString> receives Shuffle in place.
 * @topic Containers
 */
void MutateShufflePreservesMembershipFString(TArray<FString>&inout Values)
{
	Values.Shuffle();
}
/** @end */
