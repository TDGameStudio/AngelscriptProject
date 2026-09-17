/**
 * @version v1
 * @summary An &inout TSet<FName> receives a duplicate Add.
 * @topic Containers
 *
 * MutateAddDuplicateIgnoredFName
 */
/**
 * @begin MutateAddDuplicateIgnoredFName
 * @summary An &inout TSet<FName> receives a duplicate Add.
 * @topic Containers
 */
void MutateAddDuplicateIgnoredFName(TSet<FName>&inout Values)
{
	Values.Add(n"Red");
}
/** @end */
