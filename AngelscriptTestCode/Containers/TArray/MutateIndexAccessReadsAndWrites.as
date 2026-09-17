/**
 * @version v1
 * @summary An &inout TArray<int32> writes one [] slot in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWrites
 */
/**
 * @begin MutateIndexAccessReadsAndWrites
 * @summary An &inout TArray<int32> writes one [] slot in place.
 * @topic Containers
 */
void MutateIndexAccessReadsAndWrites(TArray<int32>&inout Values)
{
	Values[1] = 99;
}
/** @end */
