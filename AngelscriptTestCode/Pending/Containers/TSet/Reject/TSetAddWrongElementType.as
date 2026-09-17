/**
 * @version v1
 * @summary Add with an element of the wrong type is rejected.
 * @topic Containers
 */
/**
 * @version root
 * @summary Add with an element of the wrong type is rejected.
 * @topic Negative
 */
namespace TSetTest
{
	void Test()
	{
		TSet<int> Values;
		Values.Add("hello");
	}
}
/** @end */
