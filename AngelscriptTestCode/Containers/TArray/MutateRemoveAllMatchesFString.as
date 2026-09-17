/**
 * @version v1
 * @summary An &inout TArray<FString> has every matching element deleted by Remove.
 * @topic Containers
 *
 * MutateRemoveAllMatchesFString
 */
/**
 * @begin MutateRemoveAllMatchesFString
 * @summary An &inout TArray<FString> has every matching element deleted by Remove.
 * @topic Containers
 */
void MutateRemoveAllMatchesFString(TArray<FString>&inout Values)
{
	Values.Remove("beta");
}
/** @end */
