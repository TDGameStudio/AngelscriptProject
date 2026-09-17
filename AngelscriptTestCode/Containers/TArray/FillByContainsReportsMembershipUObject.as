/**
 * @version v1
 * @summary An &out TArray<UObject> is filled with three NewObject handles.
 * @topic Containers
 *
 * FillByContainsReportsMembershipUObject
 */
/**
 * @begin FillByContainsReportsMembershipUObject
 * @summary An &out TArray<UObject> is filled with three NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByContainsReportsMembershipUObjectHost : UObject
{
}

void FillByContainsReportsMembershipUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByContainsReportsMembershipUObjectHost::StaticClass(), n"FillByContains_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByContainsReportsMembershipUObjectHost::StaticClass(), n"FillByContains_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByContainsReportsMembershipUObjectHost::StaticClass(), n"FillByContains_2", true));
}
/** @end */
