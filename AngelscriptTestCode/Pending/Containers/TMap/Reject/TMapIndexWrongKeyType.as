/**
 * @version v1
 * @summary Bracket access with a key of the wrong type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Bracket access with a key of the wrong type is rejected.
 * @topic Negative
 */
namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		int X = Map[42];
	}
}
/** @end */
