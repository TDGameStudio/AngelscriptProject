/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPairFVector
 */
/**
 * @begin FillByRemoveKeyDropsPairFVector
 * @summary An &out TMap<int, FVector> is filled then Remove drops the middle key.
 * @topic Containers
 */
void FillByRemoveKeyDropsPairFVector(TMap<int, FVector>&out Result)
{
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	Result.Remove(2);
}
/** @end */
