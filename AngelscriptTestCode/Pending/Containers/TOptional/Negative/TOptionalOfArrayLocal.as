/**
 * @version v1
 * @summary TOptional<TArray<int>> is rejected: containers cannot be nested in other containers. Rejected at the local declaration site.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional<TArray<int>> is rejected: containers cannot be nested in other containers. Rejected at the local declaration site.
 * @topic Baseline
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional<TArray<int>> Opt;
	}
}
/** @end */
