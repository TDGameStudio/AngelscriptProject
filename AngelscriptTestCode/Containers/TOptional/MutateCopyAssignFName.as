/**
 * @version v1
 * @summary An &inout TOptional<FName> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssignFName
 */
/**
 * @begin MutateCopyAssignFName
 * @summary An &inout TOptional<FName> is overwritten by copy assignment.
 * @topic Containers
 */
void MutateCopyAssignFName(TOptional<FName>&inout Value)
{
	TOptional<FName> Other;
	Other.Set(n"Green");
	Value = Other;
}
/** @end */
