/**
 * @version v1
 * @summary An &inout TArray<int32> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicate
 */
/**
 * @begin MutateAddUniqueRejectsDuplicate
 * @summary An &inout TArray<int32> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 */
void MutateAddUniqueRejectsDuplicate(TArray<int32>&inout Values)
{
	Values.AddUnique(30);
	Values.AddUnique(20);
}
/** @end */
