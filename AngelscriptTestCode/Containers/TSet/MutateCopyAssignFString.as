/**
 * @version v1
 * @summary An &inout TSet<FString> is replaced by assigning a new set.
 * @topic Containers
 *
 * MutateCopyAssignFString
 */
/**
 * @begin MutateCopyAssignFString
 * @summary An &inout TSet<FString> is replaced by assigning a new set.
 * @topic Containers
 */
void MutateCopyAssignFString(TSet<FString>&inout Values)
{
	TSet<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Values = Source;
}
/** @end */
