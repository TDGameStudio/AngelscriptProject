/**
 * @version v1
 * @summary Default TMap<int, FVector> is empty.
 * @topic Containers
 *
 * EmptyConstructionFVector
 */
/**
 * @begin EmptyConstructionFVector
 * @summary Default TMap<int, FVector> is empty.
 * @topic Containers
 */
bool EmptyConstructionFVector()
{
	TMap<int, FVector> Map;
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
