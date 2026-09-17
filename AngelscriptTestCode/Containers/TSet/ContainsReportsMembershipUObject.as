/**
 * @version v1
 * @summary Contains is true for a UObject member that was added.
 * @topic Containers
 *
 * ContainsReportsMembershipUObject
 */
/**
 * @begin ContainsReportsMembershipUObject
 * @summary Contains is true for a UObject member that was added.
 * @topic Containers
 */
UCLASS()
class UTSetContainsReportsMembershipUObjectHost : UObject
{
}

bool ContainsReportsMembershipUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetContainsReportsMembershipUObjectHost::StaticClass(), n"ContainsReportsMembership_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetContainsReportsMembershipUObjectHost::StaticClass(), n"ContainsReportsMembership_Second", true);
	Values.Add(First);
	Values.Add(Second);
	return Values.Contains(Second);
}
/** @end */
