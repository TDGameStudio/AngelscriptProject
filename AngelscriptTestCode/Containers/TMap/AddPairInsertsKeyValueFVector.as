/**
 * @version v1
 * @summary Add inserts distinct int keys and stores each FVector value.
 * @topic Containers
 *
 * AddPairInsertsKeyValueFVector
 */
/**
 * @begin AddPairInsertsKeyValueFVector
 * @summary Add inserts distinct int keys and stores each FVector value.
 * @topic Containers
 */
bool AddPairInsertsKeyValueFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	return Map.Num() == 2
		&& Map[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Map[2].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Map.Contains(2);
}
/** @end */
