/**
 * TSet with an unknown element type is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.UnknownElementType
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetUnknownElementType
 * @Kind CompileReject
 * @Covers TSet.Declaration
 * @Inputs TSet<NonExistent> Values
 * @Return does not compile
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<NonExistent> Values;
	}
}
