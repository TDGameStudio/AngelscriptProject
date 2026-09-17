/**
 * @version v1
 * @summary An &inout TMap<FString, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKeyFString
 */
/**
 * @begin MutateContainsKeyFString
 * @summary An &inout TMap<FString, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
void MutateContainsKeyFString(TMap<FString, int>&inout Values)
{
	Values.Add("gamma", 300);
}
/** @end */
