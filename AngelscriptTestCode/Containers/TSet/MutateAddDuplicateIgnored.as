/**
 * @version v1
 * @summary An &inout TSet<int32> receives a duplicate Add.
 * @topic Containers
 *
 * MutateAddDuplicateIgnored
 */
/**
 * @begin MutateAddDuplicateIgnored
 * @summary An &inout TSet<int32> receives a duplicate Add.
 * @topic Containers
 */
void MutateAddDuplicateIgnored(TSet<int32>&inout Values)
{
	Values.Add(10);
}
/** @end */
