/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by Append of another array.
 * @topic Containers
 *
 * FillByAppendOtherArrayFVector
 */
/**
 * @begin FillByAppendOtherArrayFVector
 * @summary An &out TArray<FVector> is filled by Append of another array.
 * @topic Containers
 */
void FillByAppendOtherArrayFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	TArray<FVector> Other;
	Other.Add(FVector(0.0f, 1.0f, 0.0f));
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Append(Other);
}
/** @end */
