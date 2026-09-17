/**
 * @version v1
 * @summary TMap with void value type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary TMap with void value type is rejected.
 * @topic Negative
 */
namespace TMapTest
{
	void Test()
	{
		TMap<FString, void> Map;
	}
}
/** @end */
