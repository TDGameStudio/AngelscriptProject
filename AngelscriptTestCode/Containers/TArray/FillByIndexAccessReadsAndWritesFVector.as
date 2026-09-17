/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then [] writes one slot.
 * @topic Containers
 *
 * FillByIndexAccessReadsAndWritesFVector
 */
/**
 * @begin FillByIndexAccessReadsAndWritesFVector
 * @summary An &out TArray<FVector> is filled then [] writes one slot.
 * @topic Containers
 */
void FillByIndexAccessReadsAndWritesFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result[1] = FVector(1.0f, 1.0f, 1.0f);
}
/** @end */
