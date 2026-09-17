/**
 * @version v1
 * @summary An &inout TMap<int, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKey
 */
/**
 * @begin MutateContainsKey
 * @summary An &inout TMap<int, int> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
void MutateContainsKey(TMap<int, int>&inout Values)
{
	Values.Add(30, 300);
}
/** @end */
