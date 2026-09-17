/**
 * @version v1
 * @summary An &inout TArray<UObject> receives Swap of the end indices.
 * @topic Containers
 *
 * MutateSwapElementsUObject
 */
/**
 * @begin MutateSwapElementsUObject
 * @summary An &inout TArray<UObject> receives Swap of the end indices.
 * @topic Containers
 */
void MutateSwapElementsUObject(TArray<UObject>&inout Values)
{
	Values.Swap(0, 2);
}
/** @end */
