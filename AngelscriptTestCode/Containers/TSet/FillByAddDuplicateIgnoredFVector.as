/**
 * @version v1
 * @summary An &out TSet<FVector> is filled by Add including a skipped duplicate.
 * @topic Containers
 *
 * FillByAddDuplicateIgnoredFVector
 */
/**
 * @begin FillByAddDuplicateIgnoredFVector
 * @summary An &out TSet<FVector> is filled by Add including a skipped duplicate.
 * @topic Containers
 */
void FillByAddDuplicateIgnoredFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
