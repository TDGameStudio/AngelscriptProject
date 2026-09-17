/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then overwritten by Copy.
 * @topic Containers
 *
 * FillByCopyRangeFVector
 */
/**
 * @begin FillByCopyRangeFVector
 * @summary An &out TArray<FVector> is filled then overwritten by Copy.
 * @topic Containers
 */
void FillByCopyRangeFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(0.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 0.0f));
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Copy(Source, 0, 2, 1);
}
/** @end */
