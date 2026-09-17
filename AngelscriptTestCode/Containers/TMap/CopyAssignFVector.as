/**
 * @version v1
 * @summary Copy assignment copies FVector pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssignFVector
 */
/**
 * @begin CopyAssignFVector
 * @summary Copy assignment copies FVector pairs and stays independent of later source inserts.
 * @topic Containers
 */
bool CopyAssignFVector()
{
	TMap<int, FVector> Other;
	Other.Add(1, FVector(1.0f, 0.0f, 0.0f));
	TMap<int, FVector> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains(1) && Map[1].Equals(FVector(1.0f, 0.0f, 0.0f));
	Other.Add(2, FVector(0.0f, 1.0f, 0.0f));
	return bCopied && !Map.Contains(2) && Map.Num() == 1 && Other.Num() == 2;
}
/** @end */
