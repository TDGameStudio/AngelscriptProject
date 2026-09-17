/**
 * @version v1
 * @summary An &inout TSet<FString> receives a duplicate Add.
 * @topic Containers
 *
 * MutateAddDuplicateIgnoredFString
 */
/**
 * @begin MutateAddDuplicateIgnoredFString
 * @summary An &inout TSet<FString> receives a duplicate Add.
 * @topic Containers
 */
void MutateAddDuplicateIgnoredFString(TSet<FString>&inout Values)
{
	Values.Add("alpha");
}
/** @end */
