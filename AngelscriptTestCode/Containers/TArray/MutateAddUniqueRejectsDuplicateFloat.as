/**
 * @version v1
 * @summary An &inout TArray<float> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicateFloat
 */
/**
 * @begin MutateAddUniqueRejectsDuplicateFloat
 * @summary An &inout TArray<float> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 */
void MutateAddUniqueRejectsDuplicateFloat(TArray<float>&inout Values)
{
	Values.AddUnique(30.0f);
	Values.AddUnique(20.0f);
}
/** @end */
