/**
 * @version v1
 * @summary An &inout TArray<FString> has its first index deleted by RemoveAt.
 * @topic Containers
 *
 * MutateRemoveAtIndexFString
 */
/**
 * @begin MutateRemoveAtIndexFString
 * @summary An &inout TArray<FString> has its first index deleted by RemoveAt.
 * @topic Containers
 */
void MutateRemoveAtIndexFString(TArray<FString>&inout Values)
{
	Values.RemoveAt(0);
}
/** @end */
