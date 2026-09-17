/**
 * @version v1
 * @summary An &inout TArray<float> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFromFloat
 */
/**
 * @begin MutateMoveAssignFromFloat
 * @summary An &inout TArray<float> is replaced by MoveAssignFrom.
 * @topic Containers
 */
void MutateMoveAssignFromFloat(TArray<float>&inout Values)
{
	TArray<float> Source;
	Source.Add(1.0f);
	Source.Add(2.0f);
	Values.MoveAssignFrom(Source);
}
/** @end */
