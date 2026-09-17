/**
 * @version v1
 * @summary Contains is true for present int keys in a TMap of FVector values.
 * @topic Containers
 *
 * ContainsKeyFVector
 */
/**
 * @begin ContainsKeyFVector
 * @summary Contains is true for present int keys in a TMap of FVector values.
 * @topic Containers
 */
bool ContainsKeyFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Map.Add(3, FVector(0.0f, 0.0f, 1.0f));
	return Map.Contains(1) && Map.Contains(2) && Map.Contains(3);
}
/** @end */
