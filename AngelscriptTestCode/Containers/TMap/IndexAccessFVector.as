/**
 * @version v1
 * @summary Bracket access reads and writes an existing int key in a TMap of FVector values.
 * @topic Containers
 *
 * IndexAccessFVector
 */
/**
 * @begin IndexAccessFVector
 * @summary Bracket access reads and writes an existing int key in a TMap of FVector values.
 * @topic Containers
 */
bool IndexAccessFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	if (!Map[1].Equals(FVector(1.0f, 0.0f, 0.0f)))
	{
		return false;
	}

	Map[1] = FVector(9.0f, 9.0f, 9.0f);
	return Map[1].Equals(FVector(9.0f, 9.0f, 9.0f)) && Map.Num() == 1;
}
/** @end */
