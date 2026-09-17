/**
 * @version v1
 * @summary An &inout TSet<FName> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssignFName
 */
/**
 * @begin MutateCopyAssignFName
 * @summary An &inout TSet<FName> is replaced by assigning a new set.
 * @topic Containers
 */
void MutateCopyAssignFName(TSet<FName>&inout Values)
{
	TSet<FName> Source;
	Source.Add(n"Red");
	Source.Add(n"Green");
	Values = Source;
}
/** @end */
