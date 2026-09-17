/**
 * @version v1
 * @summary Remove deletes a present int key from an FVector map and returns false for a missing key.
 * @topic Containers
 *
 * RemoveKeyDropsPairFVector
 */
/**
 * @begin RemoveKeyDropsPairFVector
 * @summary Remove deletes a present int key from an FVector map and returns false for a missing key.
 * @topic Containers
 */
bool RemoveKeyDropsPairFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	bool bRemoved = Map.Remove(1);
	bool bMissing = Map.Remove(99);
	return bRemoved && !bMissing && Map.Num() == 1 && Map.Contains(2) && !Map.Contains(1);
}
/** @end */
