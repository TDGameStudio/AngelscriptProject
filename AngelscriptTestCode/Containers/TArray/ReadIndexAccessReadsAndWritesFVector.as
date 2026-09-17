/**
 * @version v1
 * @summary A const&in TArray<FVector> reports [] insertion order.
 * @topic Containers
 *
 * ReadIndexAccessReadsAndWritesFVector
 */
/**
 * @begin ReadIndexAccessReadsAndWritesFVector
 * @summary A const&in TArray<FVector> reports [] insertion order.
 * @topic Containers
 */
bool ReadIndexAccessReadsAndWritesFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 3
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
