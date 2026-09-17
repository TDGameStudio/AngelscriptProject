/**
 * @version v1
 * @summary An &inout TArray<FVector> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOneFVector
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOneFVector
 * @summary An &inout TArray<FVector> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 */
void MutateFindIndexReturnsFirstOrMinusOneFVector(TArray<FVector>&inout Values)
{
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
