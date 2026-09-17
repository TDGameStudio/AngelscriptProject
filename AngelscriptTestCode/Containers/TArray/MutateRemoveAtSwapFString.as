/**
 * @version v1
 * @summary An &inout TArray<FString> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwapFString
 */
/**
 * @begin MutateRemoveAtSwapFString
 * @summary An &inout TArray<FString> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwapFString(TArray<FString>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
