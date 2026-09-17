/**
 * @version v1
 * @summary TWeakObjectPtr of a struct is rejected. The template subtype must be a UObject-derived class, so a value type like FVector is not accepted.
 * @topic Containers
 */
/**
 * @version root
 * @summary TWeakObjectPtr of a struct is rejected. The template subtype must be a UObject-derived class, so a value type like FVector is not accepted.
 * @topic Negative
 */
namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<FVector> Weak;
	}
}
/** @end */
