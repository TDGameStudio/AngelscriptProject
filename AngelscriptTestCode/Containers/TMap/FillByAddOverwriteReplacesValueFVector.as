/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValueFVector
 */
/**
 * @begin FillByAddOverwriteReplacesValueFVector
 * @summary An &out TMap<int, FVector> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
void FillByAddOverwriteReplacesValueFVector(TMap<int, FVector>&out Result)
{
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.Add(1, FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
