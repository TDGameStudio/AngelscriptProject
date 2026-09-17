/**
 * @version v1
 * @summary An &inout TArray<int32> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndex
 */
/**
 * @begin MutateLastValidIndex
 * @summary An &inout TArray<int32> overwrites Last() in place.
 * @topic Containers
 */
void MutateLastValidIndex(TArray<int32>&inout Values)
{
	Values.Last() = 99;
}
/** @end */
