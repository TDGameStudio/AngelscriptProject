/**
 * @version v1
 * @summary A const&in TArray<FVector> reports assigned element order.
 * @topic Containers
 *
 * ReadCopyAssignFVector
 */
/**
 * @begin ReadCopyAssignFVector
 * @summary A const&in TArray<FVector> reports assigned element order.
 * @topic Containers
 */
bool ReadCopyAssignFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 2
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
