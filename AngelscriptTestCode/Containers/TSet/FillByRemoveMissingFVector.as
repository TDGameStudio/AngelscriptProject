/**
 * @version v1
 * @summary An &out TSet<FVector> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 *
 * FillByRemoveMissingFVector
 */
/**
 * @begin FillByRemoveMissingFVector
 * @summary An &out TSet<FVector> is filled then Remove of an absent member is a no-op.
 * @topic Containers
 */
void FillByRemoveMissingFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Remove(FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
