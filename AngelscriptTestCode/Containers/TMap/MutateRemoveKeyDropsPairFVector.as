/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Removes one present key in place.
 * @topic Containers
 *
 * MutateRemoveKeyDropsPairFVector
 */
/**
 * @begin MutateRemoveKeyDropsPairFVector
 * @summary An &inout TMap<int, FVector> Removes one present key in place.
 * @topic Containers
 */
void MutateRemoveKeyDropsPairFVector(TMap<int, FVector>&inout Values)
{
	Values.Remove(2);
}
/** @end */
