/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled by FindOrAdd of three keys.
 * @topic Containers
 *
 * FillByFindOrAddInsertsFVector
 */
/**
 * @begin FillByFindOrAddInsertsFVector
 * @summary An &out TMap<int, FVector> is filled by FindOrAdd of three keys.
 * @topic Containers
 */
void FillByFindOrAddInsertsFVector(TMap<int, FVector>&out Result)
{
	Result.FindOrAdd(1) = FVector(1.0f, 0.0f, 0.0f);
	Result.FindOrAdd(2) = FVector(0.0f, 1.0f, 0.0f);
	Result.FindOrAdd(3) = FVector(0.0f, 0.0f, 1.0f);
}
/** @end */
