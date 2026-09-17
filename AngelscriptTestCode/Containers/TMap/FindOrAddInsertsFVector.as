/**
 * @version v1
 * @summary FindOrAdd of a missing int key inserts a default FVector and does not throw.
 * @topic Containers
 *
 * FindOrAddInsertsFVector
 */
/**
 * @begin FindOrAddInsertsFVector
 * @summary FindOrAdd of a missing int key inserts a default FVector and does not throw.
 * @topic Containers
 */
bool FindOrAddInsertsFVector()
{
	TMap<int, FVector> Map;
	FVector Added = Map.FindOrAdd(2);
	return Added.Equals(FVector(0.0f, 0.0f, 0.0f))
		&& Map.Num() == 1
		&& Map.Contains(2)
		&& Map[2].Equals(FVector(0.0f, 0.0f, 0.0f));
}
/** @end */
