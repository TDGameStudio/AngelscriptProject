/**
 * @version v1
 * @summary Nested TSet<TArray<int>> as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TSet<TArray<int>> as a local is rejected.
 * @topic Baseline
 */
namespace TSetTest
{
	void Test()
	{
		TSet<TArray<int>> Groups;
	}
}
/** @end */
