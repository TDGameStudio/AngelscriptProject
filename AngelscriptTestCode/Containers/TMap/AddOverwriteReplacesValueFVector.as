/**
 * @version v1
 * @summary Add of the same int key twice keeps Num and stores the last FVector.
 * @topic Containers
 *
 * AddOverwriteReplacesValueFVector
 */
/**
 * @begin AddOverwriteReplacesValueFVector
 * @summary Add of the same int key twice keeps Num and stores the last FVector.
 * @topic Containers
 */
bool AddOverwriteReplacesValueFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	if (Map.Num() != 1 || !Map[1].Equals(FVector(1.0f, 0.0f, 0.0f)))
	{
		return false;
	}

	Map.Add(1, FVector(9.0f, 9.0f, 9.0f));
	return Map.Num() == 1 && Map.Contains(1) && Map[1].Equals(FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
