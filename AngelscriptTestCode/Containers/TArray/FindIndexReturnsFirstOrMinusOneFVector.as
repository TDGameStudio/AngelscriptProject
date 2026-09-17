/**
 * @version v1
 * @summary FindIndex returns the first matching FVector index or -1 when absent.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOneFVector
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOneFVector
 * @summary FindIndex returns the first matching FVector index or -1 when absent.
 * @topic Containers
 */
bool FindIndexReturnsFirstOrMinusOneFVector()
{
	TArray<FVector> Empty;
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	return Empty.FindIndex(FVector(1.0f, 0.0f, 0.0f)) == -1
		&& Values.FindIndex(FVector(1.0f, 0.0f, 0.0f)) == 0
		&& Values.FindIndex(FVector(0.0f, 1.0f, 0.0f)) == 1
		&& Values.FindIndex(FVector(1.0f, 1.0f, 1.0f)) == -1;
}
/** @end */
