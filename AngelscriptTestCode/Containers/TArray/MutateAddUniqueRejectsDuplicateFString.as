/**
 * @version v1
 * @summary An &inout TArray<FString> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicateFString
 */
/**
 * @begin MutateAddUniqueRejectsDuplicateFString
 * @summary An &inout TArray<FString> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 */
void MutateAddUniqueRejectsDuplicateFString(TArray<FString>&inout Values)
{
	Values.AddUnique("gamma");
	Values.AddUnique("beta");
}
/** @end */
