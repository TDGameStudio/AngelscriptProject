/**
 * @version v1
 * @summary FindOrAdd returns the existing FVector and ignores a later default.
 * @topic Containers
 *
 * FindOrAddReturnsExistingFVector
 */
/**
 * @begin FindOrAddReturnsExistingFVector
 * @summary FindOrAdd returns the existing FVector and ignores a later default.
 * @topic Containers
 */
bool FindOrAddReturnsExistingFVector()
{
	TMap<int, FVector> Map;
	FVector& WithDefault = Map.FindOrAdd(1, FVector(1.0f, 0.0f, 0.0f));
	FVector& Existing = Map.FindOrAdd(1, FVector(9.0f, 9.0f, 9.0f));
	return WithDefault.Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Map[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Existing.Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
