/**
 * @version v1
 * @summary An &inout TArray<FTransform> keeps existing slots and Add appends scale (2,3,4).
 * @topic Containers
 *
 * MutateFTransformArray
 */
/**
 * @begin MutateFTransformArray
 * @summary An &inout TArray<FTransform> keeps existing slots and Add appends scale (2,3,4).
 * @topic Containers
 */
void MutateFTransformArray(TArray<FTransform>&inout Values)
{
	Values.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
}
/** @end */
