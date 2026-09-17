/**
 * @version v1
 * @summary TSet with an unknown element type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSet with an unknown element type is rejected.
 * @topic Negative
 */
namespace TSetTest
{
	void Test()
	{
		TSet<NonExistent> Values;
	}
}
/** @end */
