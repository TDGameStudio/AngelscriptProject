/**
 * @version v1
 * @summary Reset clears every FName-key pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFName
 */
/**
 * @begin ResetClearsNumFName
 * @summary Reset clears every FName-key pair so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
