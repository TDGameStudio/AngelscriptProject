/**
 * @version v1
 * @summary An &inout TArray<float> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssignFloat
 */
/**
 * @begin MutateCopyAssignFloat
 * @summary An &inout TArray<float> is replaced by assigning a new sequence.
 * @topic Containers
 */
void MutateCopyAssignFloat(TArray<float>&inout Values)
{
	TArray<float> Source;
	Source.Add(1.0f);
	Source.Add(2.0f);
	Values = Source;
}
/** @end */
