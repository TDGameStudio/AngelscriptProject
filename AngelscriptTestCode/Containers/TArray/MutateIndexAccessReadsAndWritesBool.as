/**
 * @version v1
 * @summary An &inout TArray<bool> writes one [] slot in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWritesBool
 */
/**
 * @begin MutateIndexAccessReadsAndWritesBool
 * @summary An &inout TArray<bool> writes one [] slot in place.
 * @topic Containers
 */
void MutateIndexAccessReadsAndWritesBool(TArray<bool>&inout Values)
{
	Values[1] = false;
}
/** @end */
