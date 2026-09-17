/**
 * @version v1
 * @summary IsEmpty is true only when the map has no pairs.
 * @topic Containers
 *
 * IsEmptyTracksNum
 */
/**
 * @begin IsEmptyTracksNum
 * @summary IsEmpty is true only when the map has no pairs.
 * @topic Containers
 */
bool IsEmptyTracksNum()
{
	TMap<FName, int32> Empty;
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	return Empty.IsEmpty() && !Map.IsEmpty();
}
/** @end */
