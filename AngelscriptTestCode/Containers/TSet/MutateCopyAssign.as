/**
 * @version v1
 * @summary An &inout TSet<int32> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssign
 */
/**
 * @begin MutateCopyAssign
 * @summary An &inout TSet<int32> is replaced by assigning a new set.
 * @topic Containers
 */
void MutateCopyAssign(TSet<int32>&inout Values)
{
	TSet<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Values = Source;
}
/** @end */
