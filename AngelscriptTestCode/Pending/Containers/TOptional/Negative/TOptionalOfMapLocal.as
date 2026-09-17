/**
 * @version v1
 * @summary TOptional<TMap<int, int>> is rejected: containers cannot be nested in other containers. Rejected at the local declaration site.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional<TMap<int, int>> is rejected: containers cannot be nested in other containers. Rejected at the local declaration site.
 * @topic Baseline
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional<TMap<int, int>> Opt;
	}
}
/** @end */
