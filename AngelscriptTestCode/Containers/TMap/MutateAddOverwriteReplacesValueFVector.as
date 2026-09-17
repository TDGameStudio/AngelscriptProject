/**
 * @version v1
 * @summary An &inout TMap<int, FVector> overwrites an existing key by Add.
 * @topic Containers
 *
 * MutateAddOverwriteReplacesValueFVector
 */
/**
 * @begin MutateAddOverwriteReplacesValueFVector
 * @summary An &inout TMap<int, FVector> overwrites an existing key by Add.
 * @topic Containers
 */
void MutateAddOverwriteReplacesValueFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(1, FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
