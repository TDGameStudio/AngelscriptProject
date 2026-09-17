/**
 * @version v1
 * @summary Add with a key of the wrong type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add with a key of the wrong type is rejected.
 * @topic Negative
 */
namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		Map.Add(42, 1);
	}
}
/** @end */
