/**
 * @version v1
 * @summary An &inout TArray<bool> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFromBool
 */
/**
 * @begin MutateMoveAssignFromBool
 * @summary An &inout TArray<bool> is replaced by MoveAssignFrom.
 * @topic Containers
 */
void MutateMoveAssignFromBool(TArray<bool>&inout Values)
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Values.MoveAssignFrom(Source);
}
/** @end */
