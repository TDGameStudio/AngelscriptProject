/**
 * @version v1
 * @summary Reset clears float Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNumFloat
 */
/**
 * @begin ResetClearsNumFloat
 * @summary Reset clears float Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
bool ResetClearsNumFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add(1.0f);
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
