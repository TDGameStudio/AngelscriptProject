/**
 * @version v1
 * @summary Reset clears Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNum
 */
/**
 * @begin ResetClearsNum
 * @summary Reset clears Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
bool ResetClearsNum()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add(1);
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
