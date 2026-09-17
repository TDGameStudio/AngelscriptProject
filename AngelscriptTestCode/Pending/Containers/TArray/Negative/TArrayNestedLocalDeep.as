/**
 * @version v1
 * @summary Three-level local nesting is still nested-container reject, not a new error.
 * @topic Containers
 */
/**
 * @version root
 * @summary Three-level local nesting is still nested-container reject, not a new error.
 * @topic Baseline
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<TArray<TArray<int>>> Matrix;
	}
}
/** @end */
