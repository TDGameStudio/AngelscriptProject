/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValueFVector
 */
/**
 * @begin MutateFindValueReturnsStoredValueFVector
 * @summary An &inout TMap<int, FVector> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
void MutateFindValueReturnsStoredValueFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
