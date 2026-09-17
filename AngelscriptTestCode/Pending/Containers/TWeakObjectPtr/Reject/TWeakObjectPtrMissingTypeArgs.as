/**
 * @version v1
 * @summary TWeakObjectPtr without a template argument is rejected. The template callback requires exactly one subtype that is a UObject-derived class.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr without a template argument is rejected. The template callback requires exactly one subtype that is a UObject-derived class.
 * @topic Negative
 */
namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr Weak;
	}
}
/** @end */
