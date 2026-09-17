/**
 * @version v1
 * @summary An &inout TArray<FRotator> keeps existing slots and Add appends (10,20,30).
 * @topic Containers
 *
 * MutateFRotatorArray
 */
/**
 * @begin MutateFRotatorArray
 * @summary An &inout TArray<FRotator> keeps existing slots and Add appends (10,20,30).
 * @topic Containers
 */
void MutateFRotatorArray(TArray<FRotator>&inout Values)
{
	Values.Add(FRotator(10.0f, 20.0f, 30.0f));
}
/** @end */
