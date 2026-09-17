/**
 * @version v1
 * @summary Reset clears every FVector member so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFVector
 */
/**
 * @begin ResetClearsNumFVector
 * @summary Reset clears every FVector member so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Reset();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
