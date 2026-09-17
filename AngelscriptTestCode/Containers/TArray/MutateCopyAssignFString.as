/**
 * @version v1
 * @summary An &inout TArray<FString> is replaced by assigning a new sequence.
 * @topic Containers
 *
 * MutateCopyAssignFString
 */
/**
 * @begin MutateCopyAssignFString
 * @summary An &inout TArray<FString> is replaced by assigning a new sequence.
 * @topic Containers
 */
void MutateCopyAssignFString(TArray<FString>&inout Values)
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Values = Source;
}
/** @end */
