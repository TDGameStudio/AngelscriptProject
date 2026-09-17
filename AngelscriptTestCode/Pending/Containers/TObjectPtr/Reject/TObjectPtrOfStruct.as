/**
 * @version v1
 * @summary TObjectPtr of a struct is rejected. The template subtype must be a UObject-derived class, so a value type like FVector is not accepted.
 * @topic Containers
 */
/**
 * @version root
 * @summary TObjectPtr of a struct is rejected. The template subtype must be a UObject-derived class, so a value type like FVector is not accepted.
 * @topic Negative
 */
namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr<FVector> Ptr;
	}
}
/** @end */
