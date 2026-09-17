/**
 * @version v1
 * @summary Mutating a TMap passed by value is rejected (read-only copy).
 * @topic Containers
 */
/**
 * @version root
 * @summary Mutating a TMap passed by value is rejected (read-only copy).
 * @topic Negative
 */
namespace TMapTest
{
	int MutateByValue(TMap<int, FString> Map)
	{
		Map.Add(1, "One");
		return Map.Num();
	}
}
/** @end */
