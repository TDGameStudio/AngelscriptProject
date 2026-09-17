/**
 * @version v1
 * @summary An &inout TOptional<bool> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssignBool
 */
/**
 * @begin MutateCopyAssignBool
 * @summary An &inout TOptional<bool> is overwritten by copy assignment.
 * @topic Containers
 */
void MutateCopyAssignBool(TOptional<bool>&inout Value)
{
	TOptional<bool> Other;
	Other.Set(false);
	Value = Other;
}
/** @end */
