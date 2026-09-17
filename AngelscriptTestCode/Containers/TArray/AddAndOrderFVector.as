/**
 * @version v1
 * @summary Add appends FVector values in insertion order.
 * @topic Containers
 *
 * AddAndOrderFVector
 */
/**
 * @begin AddAndOrderFVector
 * @summary Add appends FVector values in insertion order.
 * @topic Containers
 */
bool AddAndOrderFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	return Values.Num() == 2
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
