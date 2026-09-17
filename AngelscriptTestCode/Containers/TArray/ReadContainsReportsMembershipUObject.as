/**
 * @version v1
 * @summary A const&in TArray<UObject> reports Contains by pointer identity.
 * @topic Containers
 *
 * ReadContainsReportsMembershipUObject
 */
/**
 * @begin ReadContainsReportsMembershipUObject
 * @summary A const&in TArray<UObject> reports Contains by pointer identity.
 * @topic Containers
 */
UCLASS()
class UTArrayReadContainsReportsMembershipUObjectHost : UObject
{
}

bool ReadContainsReportsMembershipUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(Values[0]) && Values.Contains(Values[1]) && Values.Contains(Values[2])
		&& Values[0] != Values[1] && Values[1] != Values[2] && Values[0] != Values[2];
}
/** @end */
