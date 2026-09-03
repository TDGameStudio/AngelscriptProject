/**
 * TOptional with an unknown element type is rejected; the template
 * callback never sees a resolvable subtype.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.UnknownElementType
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalUnknownElementType
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs TOptional<FNotAType> Opt
 * @Return does not compile
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional<FNotAType> Opt;
	}
}
