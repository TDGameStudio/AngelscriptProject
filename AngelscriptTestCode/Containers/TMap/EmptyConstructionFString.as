/**
 * @version v1
 * @summary Default TMap<FString, int> is empty.
 * @topic Containers
 *
 * EmptyConstructionFString
 */
/**
 * @begin EmptyConstructionFString
 * @summary Default TMap<FString, int> is empty.
 * @topic Containers
 */
bool EmptyConstructionFString()
{
	TMap<FString, int> Map;
	return Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
