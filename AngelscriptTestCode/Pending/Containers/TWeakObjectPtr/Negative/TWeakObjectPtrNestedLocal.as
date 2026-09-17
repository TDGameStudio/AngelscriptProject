/**
 * @version v1
 * @summary TWeakObjectPtr<TWeakObjectPtr<UObject>> is rejected: a weak pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr<TWeakObjectPtr<UObject>> is rejected: a weak pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Baseline
 */
namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<TWeakObjectPtr<UObject>> Weak;
	}
}
/** @end */
