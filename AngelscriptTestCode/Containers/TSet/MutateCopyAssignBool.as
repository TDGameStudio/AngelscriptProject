/**
 * @version v1
 * @summary An &inout TSet<bool> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssignBool
 */
/**
 * @begin MutateCopyAssignBool
 * @summary An &inout TSet<bool> is replaced by assigning a new set.
 * @topic Containers
 */
void MutateCopyAssignBool(TSet<bool>&inout Values)
{
	TSet<bool> Source;
	Source.Add(true);
	Source.Add(false);
	Values = Source;
}
/** @end */
