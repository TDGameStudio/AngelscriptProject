/**
 * @version v1
 * @summary An &out TSet<UObject> is filled so Contains can report membership.
 * @topic Containers
 *
 * FillByContainsReportsMembershipUObject
 */
/**
 * @begin FillByContainsReportsMembershipUObject
 * @summary An &out TSet<UObject> is filled so Contains can report membership.
 * @topic Containers
 */
UCLASS()
class UTSetFillByContainsReportsMembershipUObjectHost : UObject
{
}

void FillByContainsReportsMembershipUObject(TSet<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByContainsReportsMembershipUObjectHost::StaticClass(), n"FillByContainsReportsMembership_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTSetFillByContainsReportsMembershipUObjectHost::StaticClass(), n"FillByContainsReportsMembership_1", true));
}
/** @end */
