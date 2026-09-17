/**
 * @version v1
 * @summary TSubclassOf<TSubclassOf<UObject>> is rejected: a class wrapper is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSubclassOf<TSubclassOf<UObject>> is rejected: a class wrapper is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Baseline
 */
namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf<TSubclassOf<UObject>> Class;
	}
}
/** @end */
