/**
 * @version v1
 * @summary TSoftObjectPtr<TSoftObjectPtr<UObject>> is rejected: a soft pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSoftObjectPtr<TSoftObjectPtr<UObject>> is rejected: a soft pointer is itself a container, so nesting one inside another is rejected like any other nested container.
 * @topic Baseline
 */
namespace TSoftObjectPtrTest
{
	void Test()
	{
		TSoftObjectPtr<TSoftObjectPtr<UObject>> Soft;
	}
}
/** @end */
