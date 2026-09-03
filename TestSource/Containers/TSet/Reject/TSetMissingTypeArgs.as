/**
 * TSet without template parameters is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetMissingTypeArgs
 * @Kind CompileReject
 * @Covers TSet.Declaration
 * @Inputs TSet Values
 * @Return does not compile
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet Values;
	}
}
