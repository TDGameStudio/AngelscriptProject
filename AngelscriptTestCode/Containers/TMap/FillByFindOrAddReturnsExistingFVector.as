/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 *
 * FillByFindOrAddReturnsExistingFVector
 */
/**
 * @begin FillByFindOrAddReturnsExistingFVector
 * @summary An &out TMap<int, FVector> is filled by FindOrAdd with a default, then a later default is ignored.
 * @topic Containers
 */
void FillByFindOrAddReturnsExistingFVector(TMap<int, FVector>&out Result)
{
	Result.FindOrAdd(1, FVector(1.0f, 0.0f, 0.0f));
	Result.FindOrAdd(1, FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
