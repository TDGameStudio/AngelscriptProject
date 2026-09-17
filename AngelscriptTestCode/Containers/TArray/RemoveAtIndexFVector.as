/**
 * @version v1
 * @summary RemoveAt drops the indexed FVector and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndexFVector
 */
/**
 * @begin RemoveAtIndexFVector
 * @summary RemoveAt drops the indexed FVector and shifts later elements down.
 * @topic Containers
 */
bool RemoveAtIndexFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.RemoveAt(1);
	return Values.Num() == 2
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[1].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
