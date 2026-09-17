/**
 * @version v1
 * @summary An &out TArray<FVector> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 *
 * FillByFindIndexReturnsFirstOrMinusOneFVector
 */
/**
 * @begin FillByFindIndexReturnsFirstOrMinusOneFVector
 * @summary An &out TArray<FVector> is filled with a FindIndex sequence that repeats the first value.
 * @topic Containers
 */
void FillByFindIndexReturnsFirstOrMinusOneFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
