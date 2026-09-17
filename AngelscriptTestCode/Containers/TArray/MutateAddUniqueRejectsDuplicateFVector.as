/**
 * @version v1
 * @summary An &inout TArray<FVector> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 *
 * MutateAddUniqueRejectsDuplicateFVector
 */
/**
 * @begin MutateAddUniqueRejectsDuplicateFVector
 * @summary An &inout TArray<FVector> receives AddUnique of a new value and a duplicate.
 * @topic Containers
 */
void MutateAddUniqueRejectsDuplicateFVector(TArray<FVector>&inout Values)
{
	Values.AddUnique(FVector(0.0f, 0.0f, 1.0f));
	Values.AddUnique(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
