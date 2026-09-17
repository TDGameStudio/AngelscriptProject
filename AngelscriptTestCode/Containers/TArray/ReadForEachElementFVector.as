/**
 * @version v1
 * @summary A const&in TArray<FVector> is counted by range-for.
 * @topic Containers
 *
 * ReadForEachElementFVector
 */
/**
 * @begin ReadForEachElementFVector
 * @summary A const&in TArray<FVector> is counted by range-for.
 * @topic Containers
 */
bool ReadForEachElementFVector(const TArray<FVector>&in Values)
{
	int32 Count = 0;
	for (const FVector& Value : Values)
	{
		Count += 1;
	}
	return Count == 3;
}
/** @end */
