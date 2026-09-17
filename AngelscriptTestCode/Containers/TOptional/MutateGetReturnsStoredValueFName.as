/**
 * @version v1
 * @summary An &inout TOptional<FName> is overwritten so Get returns the new stored value.
 * @topic Containers
 *
 * MutateGetReturnsStoredValueFName
 */
/**
 * @begin MutateGetReturnsStoredValueFName
 * @summary An &inout TOptional<FName> is overwritten so Get returns the new stored value.
 * @topic Containers
 */
void MutateGetReturnsStoredValueFName(TOptional<FName>&inout Value)
{
	Value.Set(n"Green");
}
/** @end */
