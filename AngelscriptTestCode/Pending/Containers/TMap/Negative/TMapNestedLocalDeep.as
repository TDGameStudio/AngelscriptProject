/**
 * @version v1
 * @summary Nested TMap of TMap of TMap as a local is rejected (same diagnostic as two layers).
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap of TMap of TMap as a local is rejected (same diagnostic as two layers).
 * @topic Baseline
 */
namespace TMapTest
{
	void Test()
	{
		TMap<int, TMap<int, TMap<int, int>>> Nested;
	}
}
/** @end */
