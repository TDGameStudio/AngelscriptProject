/**
 * @version v1
 * @summary An &inout TArray<FString> Adds one value so Contains can see a new member.
 * @topic Containers
 *
 * MutateContainsReportsMembershipFString
 */
/**
 * @begin MutateContainsReportsMembershipFString
 * @summary An &inout TArray<FString> Adds one value so Contains can see a new member.
 * @topic Containers
 */
void MutateContainsReportsMembershipFString(TArray<FString>&inout Values)
{
	Values.Add("gamma");
}
/** @end */
