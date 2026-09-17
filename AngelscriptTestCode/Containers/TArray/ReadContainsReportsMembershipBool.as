/**
 * @version v1
 * @summary A const&in TArray<bool> reports Contains for both bool values.
 * @topic Containers
 *
 * ReadContainsReportsMembershipBool
 */
/**
 * @begin ReadContainsReportsMembershipBool
 * @summary A const&in TArray<bool> reports Contains for both bool values.
 * @topic Containers
 */
bool ReadContainsReportsMembershipBool(const TArray<bool>&in Values)
{
	return Values.Contains(false) && Values.Contains(true);
}
/** @end */
