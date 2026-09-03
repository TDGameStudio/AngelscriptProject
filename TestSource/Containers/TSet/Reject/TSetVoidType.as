/**
 * TSet with void element type is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.VoidType
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetVoidType
 * @Kind CompileReject
 * @Covers TSet.Declaration
 * @Inputs TSet<void> Values
 * @Return does not compile
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<void> Values;
	}
}
