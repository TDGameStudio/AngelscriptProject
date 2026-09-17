/**
 * @version v1
 * @summary An &inout TOptional<int32> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssign
 */
/**
 * @begin MutateCopyAssign
 * @summary An &inout TOptional<int32> is overwritten by copy assignment.
 * @topic Containers
 */
void MutateCopyAssign(TOptional<int32>&inout Value)
{
	TOptional<int32> Other;
	Other.Set(11);
	Value = Other;
}
/** @end */
