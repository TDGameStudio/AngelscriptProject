/**
 * @version v1
 * @summary Default TMap<FName, int> is empty.
 * @topic Containers
 *
 * EmptyConstructionFName
 */
/**
 * @begin EmptyConstructionFName
 * @summary Default TMap<FName, int> is empty.
 * @topic Containers
 */
bool EmptyConstructionFName()
{
	TMap<FName, int> Map;
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
