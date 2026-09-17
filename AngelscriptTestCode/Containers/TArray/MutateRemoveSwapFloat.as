/**
 * @version v1
 * @summary An &inout TArray<float> has every matching element deleted by RemoveSwap.
 * @topic Containers
 *
 * MutateRemoveSwapFloat
 */
/**
 * @begin MutateRemoveSwapFloat
 * @summary An &inout TArray<float> has every matching element deleted by RemoveSwap.
 * @topic Containers
 */
void MutateRemoveSwapFloat(TArray<float>&inout Values)
{
	Values.RemoveSwap(2.0f);
}
/** @end */
