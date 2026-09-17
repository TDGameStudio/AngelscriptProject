/**
 * @version v1
 * @summary An &inout TOptional<bool> is overwritten by Set.
 * @topic Containers
 *
 * MutateSetValueBool
 */
/**
 * @begin MutateSetValueBool
 * @summary An &inout TOptional<bool> is overwritten by Set.
 * @topic Containers
 */
void MutateSetValueBool(TOptional<bool>&inout Value)
{
	Value.Set(false);
}
/** @end */
