/**
 * @version v1
 * @summary Assigning a value of the wrong element type onto TOptional<int> is rejected. The implicit value constructor and opAssign both require the element type, so there is no implicit conversion from FString to int.
 * @topic Containers
 */
/**
 * @version root
 * @summary Assigning a value of the wrong element type onto TOptional<int> is rejected. The implicit value constructor and opAssign both require the element type, so there is no implicit conversion from FString to int.
 * @topic Negative
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional<int> Opt;
		Opt = "hello";
	}
}
/** @end */
