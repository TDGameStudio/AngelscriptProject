/**
 * @version v1
 * @summary RemoveSwap deletes every matching FVector and keeps a non-matching survivor.
 * @topic Containers
 *
 * RemoveSwapFVector
 */
/**
 * @begin RemoveSwapFVector
 * @summary RemoveSwap deletes every matching FVector and keeps a non-matching survivor.
 * @topic Containers
 */
bool RemoveSwapFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	int Removed = Values.RemoveSwap(FVector(1.0f, 0.0f, 0.0f));
	int Missing = Values.RemoveSwap(FVector(0.0f, 0.0f, 1.0f));
	return Removed == 2 && Missing == 0 && Values.Num() == 1
		&& Values[0].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
