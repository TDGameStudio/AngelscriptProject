/**
 * @version v1
 * @summary TWeakObjectPtr of a primitive type is rejected. The template subtype must be a UObject-derived class, so int is not accepted.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr of a primitive type is rejected. The template subtype must be a UObject-derived class, so int is not accepted.
 * @topic Negative
 */
namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<int> Weak;
	}
}
/** @end */
