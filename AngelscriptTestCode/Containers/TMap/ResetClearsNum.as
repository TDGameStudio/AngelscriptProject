/**
 * @version v1
 * @summary Reset clears every pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNum
 */
/**
 * @begin ResetClearsNum
 * @summary Reset clears every pair so Num is 0.
 * @topic Containers
 */
bool ResetClearsNum()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
