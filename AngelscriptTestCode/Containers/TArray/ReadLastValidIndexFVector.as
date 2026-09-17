/**
 * @version v1
 * @summary A const&in TArray<FVector> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndexFVector
 */
/**
 * @begin ReadLastValidIndexFVector
 * @summary A const&in TArray<FVector> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndexFVector(const TArray<FVector>&in Values)
{
	return Values.Last().Equals(FVector(0.0f, 0.0f, 1.0f))
		&& Values.Last(1).Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values.Last(2).Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
