/**
 * @version v1
 * @summary An &inout TOptional<FName> is overwritten by Set.
 * @topic Containers
 *
 * MutateSetValueFName
 */
/**
 * @begin MutateSetValueFName
 * @summary An &inout TOptional<FName> is overwritten by Set.
 * @topic Containers
 */
void MutateSetValueFName(TOptional<FName>&inout Value)
{
	Value.Set(n"Green");
}
/** @end */
