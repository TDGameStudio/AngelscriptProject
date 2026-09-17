/**
 * @version v1
 * @summary An entry returns TArray<FTransform> holding Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 *
 * ReturnFTransformArray
 */
/**
 * @begin ReturnFTransformArray
 * @summary An entry returns TArray<FTransform> holding Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 */
TArray<FTransform> ReturnFTransformArray()
{
	TArray<FTransform> Values;
	Values.Add(FTransform::Identity);
	Values.Add(FTransform(FVector(10.0f, 20.0f, 30.0f)));
	Values.Add(FTransform(FQuat::Identity, FVector(1.0f, 2.0f, 3.0f), FVector(2.0f, 3.0f, 4.0f)));
	return Values;
}
/** @end */
