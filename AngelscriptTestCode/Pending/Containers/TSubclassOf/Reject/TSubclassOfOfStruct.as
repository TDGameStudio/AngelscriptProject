/**
 * @version v1
 * @summary TSubclassOf of a struct is rejected. The template subtype must be a UObject-derived class, so a value type is not accepted.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSubclassOf of a struct is rejected. The template subtype must be a UObject-derived class, so a value type is not accepted.
 * @topic Negative
 */
namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf<FVector> Class;
	}
}
/** @end */
