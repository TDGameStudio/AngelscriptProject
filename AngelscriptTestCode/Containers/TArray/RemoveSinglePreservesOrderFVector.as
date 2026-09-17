/**
 * @version v1
 * @summary RemoveSingle removes the first matching FVector and keeps later elements in order.
 * @topic Containers
 *
 * RemoveSinglePreservesOrderFVector
 */
/**
 * @begin RemoveSinglePreservesOrderFVector
 * @summary RemoveSingle removes the first matching FVector and keeps later elements in order.
 * @topic Containers
 */
bool RemoveSinglePreservesOrderFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	int Removed = Values.RemoveSingle(FVector(1.0f, 0.0f, 0.0f));
	int Missing = Values.RemoveSingle(FVector(0.0f, 0.0f, 1.0f));
	return Removed == 1 && Missing == 0 && Values.Num() == 2
		&& Values[0].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[1].Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
