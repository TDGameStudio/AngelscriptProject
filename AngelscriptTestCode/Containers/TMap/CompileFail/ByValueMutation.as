/**
 * @version v1
 * @summary Mutating a TMap passed by value is rejected.
 * @topic Containers
 *
 * ByValueMutation
 */
/**
 * @begin ByValueMutation
 * @summary Mutating a TMap passed by value is rejected.
 * @topic Containers
 */
int ByValueMutation(TMap<int, FString> Map)
{
	Map.Add(1, "One");
	return Map.Num();
}
/** @end */
