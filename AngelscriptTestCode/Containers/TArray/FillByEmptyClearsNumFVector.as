/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFVector
 */
/**
 * @begin FillByEmptyClearsNumFVector
 * @summary An &out TArray<FVector> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Empty();
}
/** @end */
