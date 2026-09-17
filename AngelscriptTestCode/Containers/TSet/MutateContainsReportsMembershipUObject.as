/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Add so Contains becomes true.
 * @topic Containers
 *
 * MutateContainsReportsMembershipUObject
 */
/**
 * @begin MutateContainsReportsMembershipUObject
 * @summary An &inout TSet<UObject> receives Add so Contains becomes true.
 * @topic Containers
 */
UCLASS()
class UTSetMutateContainsReportsMembershipUObjectHost : UObject
{
}

void MutateContainsReportsMembershipUObject(TSet<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTSetMutateContainsReportsMembershipUObjectHost::StaticClass(), n"MutateContainsReportsMembership_New", true));
}
/** @end */
