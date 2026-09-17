/**
 * @version v1
 * @summary Nested TSet<TMap<int, int>> as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TMap<int, int>> as a local is rejected.
 * @topic Baseline
 */
namespace TSetTest
{
	void Test()
	{
		TSet<TMap<int, int>> Groups;
	}
}
/** @end */
