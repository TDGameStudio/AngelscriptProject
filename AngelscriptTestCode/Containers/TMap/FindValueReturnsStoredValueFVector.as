/**
 * @version v1
 * @summary Find copies the stored FVector and returns true for a present int key.
 * @topic Containers
 *
 * FindValueReturnsStoredValueFVector
 */
/**
 * @begin FindValueReturnsStoredValueFVector
 * @summary Find copies the stored FVector and returns true for a present int key.
 * @topic Containers
 */
bool FindValueReturnsStoredValueFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	FVector Found = FVector(0.0f, 0.0f, 0.0f);
	bool bFound = Map.Find(1, Found);
	return bFound && Found.Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
