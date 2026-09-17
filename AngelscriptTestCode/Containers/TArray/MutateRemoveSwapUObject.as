/**
 * @version v1
 * @summary An &inout TArray<UObject> has every matching handle deleted by RemoveSwap.
 * @topic Containers
 *
 * MutateRemoveSwapUObject
 */
/**
 * @begin MutateRemoveSwapUObject
 * @summary An &inout TArray<UObject> has every matching handle deleted by RemoveSwap.
 * @topic Containers
 */
void MutateRemoveSwapUObject(TArray<UObject>&inout Values)
{
	UObject Match = Values[1];
	Values.RemoveSwap(Match);
}
/** @end */
