/**
 * @version v1
 * @summary An &inout TOptional<FString> is overwritten by copy assignment.
 * @topic Containers
 *
 * MutateCopyAssignFString
 */
/**
 * @begin MutateCopyAssignFString
 * @summary An &inout TOptional<FString> is overwritten by copy assignment.
 * @topic Containers
 */
void MutateCopyAssignFString(TOptional<FString>&inout Value)
{
	TOptional<FString> Other;
	Other.Set("beta");
	Value = Other;
}
/** @end */
