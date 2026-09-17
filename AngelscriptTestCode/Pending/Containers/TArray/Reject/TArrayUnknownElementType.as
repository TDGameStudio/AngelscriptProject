/**
 * @version v1
 * @summary TArray of an undeclared element type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary TArray of an undeclared element type is rejected.
 * @topic Negative
 */
namespace TArrayTest
{
	void Test()
	{
		TArray<NonExistent> Arr;
	}
}
/** @end */
