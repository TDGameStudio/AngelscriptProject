/**
 * @version v1
 * @summary TSubclassOf without a template argument is rejected. The template requires exactly one class subtype.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSubclassOf without a template argument is rejected. The template requires exactly one class subtype.
 * @topic Negative
 */
namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf Class;
	}
}
/** @end */
