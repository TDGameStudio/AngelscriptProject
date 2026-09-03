/**
 * TSubclassOf without a template argument is rejected. The template
 * requires exactly one class subtype.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TSubclassOf.TSubclassOfMissingTypeArgs
 * @Kind CompileReject
 * @Covers TSubclassOf.Declaration
 * @Inputs TSubclassOf Class
 * @Return does not compile
 * @Namespace TSubclassOfTest
 */

namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf Class;
	}
}
