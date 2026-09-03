/**
 * Add with an element of the wrong type is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.AddWrongElementType
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetAddWrongElementType
 * @Kind CompileReject
 * @Covers TSet.Add
 * @Inputs TSet<int>; Add("hello")
 * @Return does not compile
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<int> Values;
		Values.Add("hello");
	}
}
