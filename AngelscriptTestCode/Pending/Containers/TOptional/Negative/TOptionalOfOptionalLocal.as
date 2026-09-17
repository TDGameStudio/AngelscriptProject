/**
 * @version v1
 * @summary TOptional<TOptional<int>> is rejected: an optional is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional<TOptional<int>> is rejected: an optional is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Baseline
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional<TOptional<int>> Opt;
	}
}
/** @end */
