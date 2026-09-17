/**
 * @version v1
 * @summary An &inout TMap<int, FVector> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 *
 * MutateGetKeysListsPresentKeysFVector
 */
/**
 * @begin MutateGetKeysListsPresentKeysFVector
 * @summary An &inout TMap<int, FVector> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 */
void MutateGetKeysListsPresentKeysFVector(TMap<int, FVector>&inout Values)
{
	Values.Add(3, FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
