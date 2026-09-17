/**
 * @version v1
 * @summary Empty clears every FVector pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFVector
 */
/**
 * @begin EmptyClearsNumFVector
 * @summary Empty clears every FVector pair so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
