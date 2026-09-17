/**
 * @version v1
 * @summary Nested TMap whose value is TSet as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap whose value is TSet as a local is rejected.
 * @topic Baseline
 */
namespace TMapTest
{
	void Test()
	{
		TMap<int, TSet<int>> Groups;
	}
}
/** @end */
