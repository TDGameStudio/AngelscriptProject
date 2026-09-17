/**
 * @version v1
 * @summary A const&in TSet<UObject> reports Contains for each present handle.
 * @topic Containers
 *
 * ReadContainsReportsMembershipUObject
 */
/**
 * @begin ReadContainsReportsMembershipUObject
 * @summary A const&in TSet<UObject> reports Contains for each present handle.
 * @topic Containers
 */
bool ReadContainsReportsMembershipUObject(const TSet<UObject>&in Values)
{
	int32 Count = 0;
	for (UObject Item : Values)
	{
		if (Item == nullptr || !Values.Contains(Item))
		{
			return false;
		}
		Count += 1;
	}
	return Count == Values.Num() && Values.Num() == 2;
}
/** @end */
