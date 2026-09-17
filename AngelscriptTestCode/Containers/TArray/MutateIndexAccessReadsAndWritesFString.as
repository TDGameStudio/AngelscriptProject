/**
 * @version v1
 * @summary An &inout TArray<FString> writes one [] slot in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWritesFString
 */
/**
 * @begin MutateIndexAccessReadsAndWritesFString
 * @summary An &inout TArray<FString> writes one [] slot in place.
 * @topic Containers
 */
void MutateIndexAccessReadsAndWritesFString(TArray<FString>&inout Values)
{
	Values[1] = "omega";
}
/** @end */
