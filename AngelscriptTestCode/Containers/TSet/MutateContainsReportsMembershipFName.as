/**
 * @version v1
 * @summary An &inout TSet<FName> receives Add so Contains becomes true.
 * @topic Containers
 *
 * MutateContainsReportsMembershipFName
 */
/**
 * @begin MutateContainsReportsMembershipFName
 * @summary An &inout TSet<FName> receives Add so Contains becomes true.
 * @topic Containers
 */
void MutateContainsReportsMembershipFName(TSet<FName>&inout Values)
{
	Values.Add(n"Green");
}
/** @end */
