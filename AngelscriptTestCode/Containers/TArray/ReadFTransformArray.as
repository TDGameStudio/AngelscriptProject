/**
 * @version v1
 * @summary A const&in TArray<FTransform> reports Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 *
 * ReadFTransformArray
 */
/**
 * @begin ReadFTransformArray
 * @summary A const&in TArray<FTransform> reports Identity, translation (10,20,30), and scale (2,3,4).
 * @topic Containers
 */
bool ReadFTransformArray(const TArray<FTransform>&in Values)
{
	return Values.Num() == 3
		&& Values[0].Equals(FTransform::Identity, 0.001f)
		&& Values[1].GetLocation().Equals(FVector(10.0f, 20.0f, 30.0f), 0.001f)
		&& Values[2].GetScale3D().Equals(FVector(2.0f, 3.0f, 4.0f), 0.001f);
}
/** @end */
