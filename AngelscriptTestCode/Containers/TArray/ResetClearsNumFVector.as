/**
 * @version v1
 * @summary Reset clears FVector Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 *
 * ResetClearsNumFVector
 */
/**
 * @begin ResetClearsNumFVector
 * @summary Reset clears FVector Num to 0 and Reset(4) retains Max of at least 4.
 * @topic Containers
 */
bool ResetClearsNumFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Reset();
	bool bDefaultReset = Values.IsEmpty();
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Reset(4);
	return bDefaultReset && Values.IsEmpty() && Values.Max() >= 4;
}
/** @end */
