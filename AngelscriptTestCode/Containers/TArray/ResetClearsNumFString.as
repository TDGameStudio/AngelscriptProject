/**
 * @version v1
 * @summary Reset clears FString Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNumFString
 */
/**
 * @begin ResetClearsNumFString
 * @summary Reset clears FString Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
bool ResetClearsNumFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add("alpha");
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
