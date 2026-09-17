/**
 * @version v1
 * @summary IsEmpty is true for a default array and false after Add.
 * @topic Containers
 *
 * IsEmptyTracksNum
 */
/**
 * @begin IsEmptyTracksNum
 * @summary IsEmpty is true for a default array and false after Add.
 * @topic Containers
 */
bool IsEmptyTracksNum()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	return Empty.IsEmpty() && !Values.IsEmpty();
}
/** @end */
