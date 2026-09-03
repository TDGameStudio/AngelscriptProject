/**
 * TOptional<TOptional<int>> is rejected: an optional is itself a container,
 * so nesting one inside another is rejected like any other nested container.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.NestedOptional
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalOfOptionalLocal
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs TOptional<TOptional<int>> Opt
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional<TOptional<int>> Opt;
	}
}
