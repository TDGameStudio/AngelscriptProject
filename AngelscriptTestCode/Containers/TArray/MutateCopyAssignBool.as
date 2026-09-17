/**
 * @version v1
 * @summary An &inout TArray<bool> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssignBool
 */
/**
 * @begin MutateCopyAssignBool
 * @summary An &inout TArray<bool> is replaced by assigning a new sequence.
 * @topic Containers
 */
void MutateCopyAssignBool(TArray<bool>&inout Values)
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Values = Source;
}
/** @end */
