/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValueFVector
 */
/**
 * @begin FillByRemoveAndCopyValueFVector
 * @summary An &out TMap<int, FVector> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
void FillByRemoveAndCopyValueFVector(TMap<int, FVector>&out Result)
{
	FVector OutValue = FVector(0.0f, 0.0f, 0.0f);
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.RemoveAndCopyValue(1, OutValue);
}
/** @end */
