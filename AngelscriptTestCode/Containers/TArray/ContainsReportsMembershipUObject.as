/**
 * @version v1
 * @summary Contains is true for a present UObject handle and false for a stranger.
 * @topic Containers
 *
 * ContainsReportsMembershipUObject
 */
/**
 * @begin ContainsReportsMembershipUObject
 * @summary Contains is true for a present UObject handle and false for a stranger.
 * @topic Containers
 */
UCLASS()
class UTArrayContainsReportsMembershipUObjectHost : UObject
{
}

bool ContainsReportsMembershipUObject()
{
	TArray<UObject> Empty;
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayContainsReportsMembershipUObjectHost::StaticClass(), n"Contains_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayContainsReportsMembershipUObjectHost::StaticClass(), n"Contains_Second", true);
	UObject Stranger = NewObject(GetTransientPackage(), UTArrayContainsReportsMembershipUObjectHost::StaticClass(), n"Contains_Stranger", true);
	Values.Add(First);
	Values.Add(Second);
	return !Empty.Contains(First) && Values.Contains(Second) && !Values.Contains(Stranger);
}
/** @end */
