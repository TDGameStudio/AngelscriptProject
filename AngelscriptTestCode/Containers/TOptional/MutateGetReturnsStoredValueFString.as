/**
 * @version v1
 * @summary An &inout TOptional<FString> is overwritten so Get returns the new stored value.
 * @topic Containers
 *
 * MutateGetReturnsStoredValueFString
 */
/**
 * @begin MutateGetReturnsStoredValueFString
 * @summary An &inout TOptional<FString> is overwritten so Get returns the new stored value.
 * @topic Containers
 */
void MutateGetReturnsStoredValueFString(TOptional<FString>&inout Value)
{
	Value.Set("beta");
}
/** @end */
