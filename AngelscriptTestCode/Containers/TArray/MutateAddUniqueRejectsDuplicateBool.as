/**
 * @version v1
 * @summary An &inout TArray<bool> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicateBool
 */
/**
 * @begin MutateAddUniqueRejectsDuplicateBool
 * @summary An &inout TArray<bool> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 */
void MutateAddUniqueRejectsDuplicateBool(TArray<bool>&inout Values)
{
	Values.AddUnique(false);
	Values.AddUnique(true);
}
/** @end */
