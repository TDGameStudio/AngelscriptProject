/**
 * @version v1
 * @summary Nested TMap whose value is TArray as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TMap whose value is TArray as a local is rejected.
 * @topic Baseline
 */
namespace TMapTest
{
	void Test()
	{
		TMap<int, TArray<int>> Groups;
	}
}
/** @end */
