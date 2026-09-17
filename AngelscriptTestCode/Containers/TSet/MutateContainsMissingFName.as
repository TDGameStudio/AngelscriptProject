/**
 * @version v1
 * @summary An &inout TSet<FName> receives Add of a present member only.
 * @topic Containers
 *
 * MutateContainsMissingFName
 */
/**
 * @begin MutateContainsMissingFName
 * @summary An &inout TSet<FName> receives Add of a present member only.
 * @topic Containers
 */
void MutateContainsMissingFName(TSet<FName>&inout Values)
{
	Values.Add(n"Red");
}
/** @end */
