/**
 * @version v1
 * @summary Nested TSet<TSet<int>> as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TSet<int>> as a local is rejected.
 * @topic Baseline
 */
namespace TSetTest
{
	void Test()
	{
		TSet<TSet<int>> Nested;
	}
}
/** @end */
