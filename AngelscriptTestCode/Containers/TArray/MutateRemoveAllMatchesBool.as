/**
 * @version v1
 * @summary An &inout TArray<bool> has every matching element deleted by Remove.
 * @topic Containers
 *
 * MutateRemoveAllMatchesBool
 */
/**
 * @begin MutateRemoveAllMatchesBool
 * @summary An &inout TArray<bool> has every matching element deleted by Remove.
 * @topic Containers
 */
void MutateRemoveAllMatchesBool(TArray<bool>&inout Values)
{
	Values.Remove(true);
}
/** @end */
