/**
 * @version v1
 * @summary TMap with an unknown value type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary TMap with an unknown value type is rejected.
 * @topic Negative
 */
namespace TMapTest
{
	void Test()
	{
		TMap<int, NonExistent> Map;
	}
}
/** @end */
