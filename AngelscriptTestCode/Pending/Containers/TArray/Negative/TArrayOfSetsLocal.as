/**
 * @version v1
 * @summary Nested TArray of TSet as a local is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Nested TArray of TSet as a local is rejected.
 * @topic Baseline
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<TSet<int>> Rows;
	}
}
/** @end */
