/**
 * @version v1
 * @summary Reset clears bool Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNumBool
 */
/**
 * @begin ResetClearsNumBool
 * @summary Reset clears bool Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
bool ResetClearsNumBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add(true);
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
