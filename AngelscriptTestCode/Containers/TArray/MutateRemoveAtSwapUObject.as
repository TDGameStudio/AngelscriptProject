/**
 * @version v1
 * @summary An &inout TArray<UObject> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 *
 * MutateRemoveAtSwapUObject
 */
/**
 * @begin MutateRemoveAtSwapUObject
 * @summary An &inout TArray<UObject> has its first index deleted by RemoveAtSwap.
 * @topic Containers
 */
void MutateRemoveAtSwapUObject(TArray<UObject>&inout Values)
{
	Values.RemoveAtSwap(0);
}
/** @end */
