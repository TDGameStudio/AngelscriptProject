/**
 * @version v1
 * @summary An &inout TOptional<FString> is overwritten by Set.
 * @topic Containers
 *
 * MutateSetValueFString
 */
/**
 * @begin MutateSetValueFString
 * @summary An &inout TOptional<FString> is overwritten by Set.
 * @topic Containers
 */
void MutateSetValueFString(TOptional<FString>&inout Value)
{
	Value.Set("beta");
}
/** @end */
