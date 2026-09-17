/**
 * @version v1
 * @summary An &inout TMap<int, bool> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKeyBool
 */
/**
 * @begin MutateContainsKeyBool
 * @summary An &inout TMap<int, bool> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
void MutateContainsKeyBool(TMap<int, bool>&inout Values)
{
	Values.Add(3, true);
}
/** @end */
