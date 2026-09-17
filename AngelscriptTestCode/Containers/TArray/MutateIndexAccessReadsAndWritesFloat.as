/**
 * @version v1
 * @summary An &inout TArray<float> writes one [] slot in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWritesFloat
 */
/**
 * @begin MutateIndexAccessReadsAndWritesFloat
 * @summary An &inout TArray<float> writes one [] slot in place.
 * @topic Containers
 */
void MutateIndexAccessReadsAndWritesFloat(TArray<float>&inout Values)
{
	Values[1] = 99.0f;
}
/** @end */
