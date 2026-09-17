/**
 * @version v1
 * @summary An &out TMap<int, FVector> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFVector
 */
/**
 * @begin FillByEmptyClearsNumFVector
 * @summary An &out TMap<int, FVector> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFVector(TMap<int, FVector>&out Result)
{
	Result.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Result.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Result.Add(3, FVector(0.0f, 0.0f, 1.0f));
	Result.Empty();
}
/** @end */
