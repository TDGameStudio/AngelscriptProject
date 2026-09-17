/**
 * @version v1
 * @summary An &inout TOptional<FString> is rewritten through GetValue.
 * @topic Containers
 *
 * MutateGetValueReturnsStoredIntFString
 */
/**
 * @begin MutateGetValueReturnsStoredIntFString
 * @summary An &inout TOptional<FString> is rewritten through GetValue.
 * @topic Containers
 */
void MutateGetValueReturnsStoredIntFString(TOptional<FString>&inout Value)
{
	Value.GetValue() = "beta";
}
/** @end */
