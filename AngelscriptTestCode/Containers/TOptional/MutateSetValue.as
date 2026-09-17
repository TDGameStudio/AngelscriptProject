/**
 * @version v1
 * @summary An &inout TOptional<int32> is overwritten by Set.
 * @topic Containers
 *
 * MutateSetValue
 */
/**
 * @begin MutateSetValue
 * @summary An &inout TOptional<int32> is overwritten by Set.
 * @topic Containers
 */
void MutateSetValue(TOptional<int32>&inout Value)
{
	Value.Set(11);
}
/** @end */
