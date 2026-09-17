/**
 * @version v1
 * @summary An &out TArray<FTransform> is filled with Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 *
 * FillByFTransformArray
 */
/**
 * @begin FillByFTransformArray
 * @summary An &out TArray<FTransform> is filled with Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 */
void FillByFTransformArray(TArray<FTransform>&out Result)
{
	Result.Add(FTransform::Identity);
	Result.Add(FTransform(FVector(10.0f, 20.0f, 30.0f)));
	Result.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
}
/** @end */
