/**
 * @version v1
 * @summary An &inout TArray<bool> Adds false so Contains can see both values.
 * @topic Containers
 *
 * MutateContainsReportsMembershipBool
 */
/**
 * @begin MutateContainsReportsMembershipBool
 * @summary An &inout TArray<bool> Adds false so Contains can see both values.
 * @topic Containers
 */
void MutateContainsReportsMembershipBool(TArray<bool>&inout Values)
{
	Values.Add(false);
}
/** @end */
