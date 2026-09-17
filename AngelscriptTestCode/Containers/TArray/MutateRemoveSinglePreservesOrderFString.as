/**
 * @version v1
 * @summary An &inout TArray<FString> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrderFString
 */
/**
 * @begin MutateRemoveSinglePreservesOrderFString
 * @summary An &inout TArray<FString> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrderFString(TArray<FString>&inout Values)
{
	Values.RemoveSingle("b");
}
/** @end */
