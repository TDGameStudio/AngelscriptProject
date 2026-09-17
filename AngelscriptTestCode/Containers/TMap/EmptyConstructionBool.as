/**
 * @version v1
 * @summary Default TMap<int, bool> is empty.
 * @topic Containers
 *
 * EmptyConstructionBool
 */
/**
 * @begin EmptyConstructionBool
 * @summary Default TMap<int, bool> is empty.
 * @topic Containers
 */
bool EmptyConstructionBool()
{
	TMap<int, bool> Map;
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
