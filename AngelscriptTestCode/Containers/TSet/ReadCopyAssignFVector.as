/**
 * @version v1
 * @summary A const&in TSet<FVector> reports assigned membership.
 * @topic Containers
 *
 * ReadCopyAssignFVector
 */
/**
 * @begin ReadCopyAssignFVector
 * @summary A const&in TSet<FVector> reports assigned membership.
 * @topic Containers
 */
bool ReadCopyAssignFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 2
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
