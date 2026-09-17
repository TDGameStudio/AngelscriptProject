/**
 * @version v1
 * @summary A const&in TArray<int32> reports Contains for present and absent values.
 * @topic Containers
 *
 * ReadContainsReportsMembership
 */
/**
 * @begin ReadContainsReportsMembership
 * @summary A const&in TArray<int32> reports Contains for present and absent values.
 * @topic Containers
 */
bool ReadContainsReportsMembership(const TArray<int32>&in Values)
{
	return Values.Contains(10) && Values.Contains(20) && Values.Contains(30) && !Values.Contains(99);
}
/** @end */
