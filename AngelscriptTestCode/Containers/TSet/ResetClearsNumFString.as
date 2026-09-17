/**
 * @version v1
 * @summary Reset clears every FString member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFString
 */
/**
 * @begin ResetClearsNumFString
 * @summary Reset clears every FString member so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
