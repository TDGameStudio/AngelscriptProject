/**
 * @version v1
 * @summary Reset clears every bool member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumBool
 */
/**
 * @begin ResetClearsNumBool
 * @summary Reset clears every bool member so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
