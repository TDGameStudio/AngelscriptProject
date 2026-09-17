/**
 * @version v1
 * @summary Reset clears every member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNum
 */
/**
 * @begin ResetClearsNum
 * @summary Reset clears every member so Num is 0.
 * @topic Containers
 */
bool ResetClearsNum()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
