/**
 * @version v1
 * @summary An &inout TSet<int32> receives Add so Contains becomes true.
 * @topic Containers
 *
 * MutateContainsReportsMembership
 */
/**
 * @begin MutateContainsReportsMembership
 * @summary An &inout TSet<int32> receives Add so Contains becomes true.
 * @topic Containers
 */
void MutateContainsReportsMembership(TSet<int32>&inout Values)
{
	Values.Add(2);
}
/** @end */
