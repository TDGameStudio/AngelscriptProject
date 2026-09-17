/**
 * @version v1
 * @summary An &inout TOptional<FName> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredIntFName
 */
/**
 * @begin MutateGetValueReturnsStoredIntFName
 * @summary An &inout TOptional<FName> is rewritten through GetValue.
 * @topic Containers
 */
void MutateGetValueReturnsStoredIntFName(TOptional<FName>&inout Value)
{
	Value.GetValue() = n"Green";
}
/** @end */
