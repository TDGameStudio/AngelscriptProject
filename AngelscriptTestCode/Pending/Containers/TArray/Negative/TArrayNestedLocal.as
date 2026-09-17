/**
 * @version v1
 * @summary Nested TArray<TArray<int>> as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray<TArray<int>> as a local is rejected.
 * @topic Baseline
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<TArray<int>> Arr;
	}
}
/** @end */
