/**
 * @version v1
 * @summary Add with a value of the wrong type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add with a value of the wrong type is rejected.
 * @topic Negative
 */
namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		Map.Add("key", "value");
	}
}
/** @end */
