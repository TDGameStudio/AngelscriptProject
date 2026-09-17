/**
 * @version v1
 * @summary An &inout TMap<FName, int> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 *
 * MutateGetKeysListsPresentKeysFName
 */
/**
 * @begin MutateGetKeysListsPresentKeysFName
 * @summary An &inout TMap<FName, int> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 */
void MutateGetKeysListsPresentKeysFName(TMap<FName, int>&inout Values)
{
	Values.Add(n"Blue", 3);
}
/** @end */
