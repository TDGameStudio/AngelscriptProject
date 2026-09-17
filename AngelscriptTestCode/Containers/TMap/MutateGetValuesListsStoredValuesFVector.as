/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 *
 * MutateGetValuesListsStoredValuesFVector
 */
/**
 * @begin MutateGetValuesListsStoredValuesFVector
 * @summary An &inout TMap<int, FVector> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 */
void MutateGetValuesListsStoredValuesFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
