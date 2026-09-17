/**
 * @version v1
 * @summary Reset clears every FVector pair so Num is 0.
 * @topic Containers
 *
 * ResetClearsNumFVector
 */
/**
 * @begin ResetClearsNumFVector
 * @summary Reset clears every FVector pair so Num is 0.
 * @topic Containers
 */
bool ResetClearsNumFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Reset();
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
