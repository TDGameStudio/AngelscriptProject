/**
 * @version v1
 * @summary An &inout TArray<int32> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssign
 */
/**
 * @begin MutateCopyAssign
 * @summary An &inout TArray<int32> is replaced by assigning a new sequence.
 * @topic Containers
 */
void MutateCopyAssign(TArray<int32>&inout Values)
{
	TArray<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Values = Source;
}
/** @end */
