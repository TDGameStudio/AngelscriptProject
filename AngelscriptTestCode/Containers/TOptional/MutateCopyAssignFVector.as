/**
 * @version v1
 * @summary An &inout TOptional<FVector> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssignFVector
 */
/**
 * @begin MutateCopyAssignFVector
 * @summary An &inout TOptional<FVector> is overwritten by copy assignment.
 * @topic Containers
 */
void MutateCopyAssignFVector(TOptional<FVector>&inout Value)
{
	TOptional<FVector> Other;
	Other.Set(FVector(0.0f, 1.0f, 0.0f));
	Value = Other;
}
/** @end */
