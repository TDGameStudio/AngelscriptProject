/**
 * @version v1
 * @summary Reset clears every FName member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFName
 */
/**
 * @begin ResetClearsNumFName
 * @summary Reset clears every FName member so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
