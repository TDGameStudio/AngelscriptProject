/**
 * @version v1
 * @summary An &inout TSet<FString> receives Add so Contains becomes true.
 * @topic Containers
 *
 * MutateContainsReportsMembershipFString
 */
/**
 * @begin MutateContainsReportsMembershipFString
 * @summary An &inout TSet<FString> receives Add so Contains becomes true.
 * @topic Containers
 */
void MutateContainsReportsMembershipFString(TSet<FString>&inout Values)
{
	Values.Add("beta");
}
/** @end */
