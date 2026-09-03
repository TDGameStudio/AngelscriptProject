/**
 * TOptional without a template argument is rejected. The template is
 * declared as TOptional<class T>, so the argument is mandatory.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalMissingTypeArgs
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs TOptional Opt
 * @Return does not compile
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional Opt;
	}
}
