/**
 * @version v1
 * @summary TObjectPtr without a template argument is rejected. The template callback requires exactly one subtype that is a UObject-derived class.
 * @topic Containers
 */
/**
 * @version root
 * @summary TObjectPtr without a template argument is rejected. The template callback requires exactly one subtype that is a UObject-derived class.
 * @topic Negative
 */
namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr Ptr;
	}
}
/** @end */
