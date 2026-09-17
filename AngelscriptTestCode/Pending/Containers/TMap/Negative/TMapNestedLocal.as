/**
 * @version v1
 * @summary Nested TMap<int, TMap<int, int>> as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap<int, TMap<int, int>> as a local is rejected.
 * @topic Baseline
 */
namespace TMapTest
{
	void Test()
	{
		TMap<int, TMap<int, int>> Nested;
	}
}
/** @end */
