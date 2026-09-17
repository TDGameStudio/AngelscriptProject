/**
 * @version v1
 * @summary An &inout TSet<FName> receives Remove of an absent member.
 * @topic Containers
 *
 * MutateRemoveMissingFName
 */
/**
 * @begin MutateRemoveMissingFName
 * @summary An &inout TSet<FName> receives Remove of an absent member.
 * @topic Containers
 */
void MutateRemoveMissingFName(TSet<FName>&inout Values)
{
	Values.Remove(n"Missing");
}
/** @end */
