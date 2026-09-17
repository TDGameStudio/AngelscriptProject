/**
 * @version v1
 * @summary An &inout TMap<FName, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKeyFName
 */
/**
 * @begin MutateContainsKeyFName
 * @summary An &inout TMap<FName, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
void MutateContainsKeyFName(TMap<FName, int>&inout Values)
{
	Values.Add(n"Blue", 3);
}
/** @end */
