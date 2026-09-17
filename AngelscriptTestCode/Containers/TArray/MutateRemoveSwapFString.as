/**
 * @version v1
 * @summary An &inout TArray<FString> has every matching element deleted by RemoveSwap.
 * @topic Containers
 *
 * MutateRemoveSwapFString
 */
/**
 * @begin MutateRemoveSwapFString
 * @summary An &inout TArray<FString> has every matching element deleted by RemoveSwap.
 * @topic Containers
 */
void MutateRemoveSwapFString(TArray<FString>&inout Values)
{
	Values.RemoveSwap("b");
}
/** @end */
