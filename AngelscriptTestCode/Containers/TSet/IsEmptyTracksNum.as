/**
 * @version v1
 * @summary IsEmpty is true only when the set has no members.
 * @topic Containers
 *
 * IsEmptyTracksNum
 */
/**
 * @begin IsEmptyTracksNum
 * @summary IsEmpty is true only when the set has no members.
 * @topic Containers
 */
bool IsEmptyTracksNum()
{
	TSet<int32> Empty;
	TSet<int32> Values;
	Values.Add(1);
	return Empty.IsEmpty() && !Values.IsEmpty();
}
/** @end */
