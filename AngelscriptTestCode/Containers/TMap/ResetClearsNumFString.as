/**
 * @version v1
 * @summary Reset clears every FString-key pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFString
 */
/**
 * @begin ResetClearsNumFString
 * @summary Reset clears every FString-key pair so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
