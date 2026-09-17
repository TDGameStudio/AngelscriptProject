/**
 * @version v1
 * @summary An &inout TArray<FVector> keeps existing slots and Add appends one more.
 * @topic Containers
 *
 * AppendWithAddFVector
 */
/**
 * @begin AppendWithAddFVector
 * @summary An &inout TArray<FVector> keeps existing slots and Add appends one more.
 * @topic Containers
 */
void AppendWithAddFVector(TArray<FVector>&inout Values)
{
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
