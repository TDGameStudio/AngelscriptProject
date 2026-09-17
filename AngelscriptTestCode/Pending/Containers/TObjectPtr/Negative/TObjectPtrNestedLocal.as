/**
 * @version v1
 * @summary TObjectPtr<TObjectPtr<UObject>> is rejected: an object pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Containers
 */
/**
 * @version root
 * @summary TObjectPtr<TObjectPtr<UObject>> is rejected: an object pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Baseline
 */
namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr<TObjectPtr<UObject>> Ptr;
	}
}
/** @end */
