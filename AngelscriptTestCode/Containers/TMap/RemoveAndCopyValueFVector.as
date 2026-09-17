/**
 * @version v1
 * @summary RemoveAndCopyValue copies the FVector out and leaves a missing key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValueFVector
 */
/**
 * @begin RemoveAndCopyValueFVector
 * @summary RemoveAndCopyValue copies the FVector out and leaves a missing key unchanged.
 * @topic Containers
 */
bool RemoveAndCopyValueFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	FVector OutValue = FVector(0.0f, 0.0f, 0.0f);
	bool bRemoved = Map.RemoveAndCopyValue(1, OutValue);
	FVector MissingOut = FVector(9.0f, 9.0f, 9.0f);
	bool bMissing = Map.RemoveAndCopyValue(1, MissingOut);
	return bRemoved
		&& OutValue.Equals(FVector(1.0f, 0.0f, 0.0f))
		&& !bMissing
		&& MissingOut.Equals(FVector(9.0f, 9.0f, 9.0f))
		&& Map.IsEmpty();
}
/** @end */
