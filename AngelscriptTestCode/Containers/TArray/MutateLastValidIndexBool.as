/**
 * @version v1
 * @summary An &inout TArray<bool> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndexBool
 */
/**
 * @begin MutateLastValidIndexBool
 * @summary An &inout TArray<bool> overwrites Last() in place.
 * @topic Containers
 */
void MutateLastValidIndexBool(TArray<bool>&inout Values)
{
	Values.Last() = true;
}
/** @end */
