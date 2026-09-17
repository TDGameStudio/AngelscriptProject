/**
 * @version v1
 * @summary An &inout TArray<int32> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFrom
 */
/**
 * @begin MutateMoveAssignFrom
 * @summary An &inout TArray<int32> is replaced by MoveAssignFrom.
 * @topic Containers
 */
void MutateMoveAssignFrom(TArray<int32>&inout Values)
{
	TArray<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Values.MoveAssignFrom(Source);
}
/** @end */
