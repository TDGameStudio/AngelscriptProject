/**
 * @version v1
 * @summary Reset clears every bool pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumBool
 */
/**
 * @begin ResetClearsNumBool
 * @summary Reset clears every bool pair so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
