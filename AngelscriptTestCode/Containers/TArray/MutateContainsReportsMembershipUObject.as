/**
 * @version v1
 * @summary An &inout TArray<UObject> Adds one NewObject so Contains can see a new identity.
 * @topic Containers
 *
 * MutateContainsReportsMembershipUObject
 */
/**
 * @begin MutateContainsReportsMembershipUObject
 * @summary An &inout TArray<UObject> Adds one NewObject so Contains can see a new identity.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateContainsReportsMembershipUObjectHost : UObject
{
}

void MutateContainsReportsMembershipUObject(TArray<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTArrayMutateContainsReportsMembershipUObjectHost::StaticClass(), n"MutateContains_Tail", true));
}
/** @end */
