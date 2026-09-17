/**
 * @version v1
 * @summary A const&in TArray<FVector> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 *
 * ReadRemoveAtIndexFVector
 */
/**
 * @begin ReadRemoveAtIndexFVector
 * @summary A const&in TArray<FVector> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 */
bool ReadRemoveAtIndexFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 2
		&& Values[0].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
