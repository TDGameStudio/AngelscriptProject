/**
 * @version v1
 * @summary RemoveAtSwap drops the indexed FVector and may reorder survivors.
 * @topic Containers
 *
 * RemoveAtSwapFVector
 */
/**
 * @begin RemoveAtSwapFVector
 * @summary RemoveAtSwap drops the indexed FVector and may reorder survivors.
 * @topic Containers
 */
bool RemoveAtSwapFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.RemoveAtSwap(0);
	return Values.Num() == 2
		&& !Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& !Values[1].Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
