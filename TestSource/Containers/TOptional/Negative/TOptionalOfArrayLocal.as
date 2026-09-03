/**
 * TOptional<TArray<int>> is rejected: containers cannot be nested in other
 * containers. Rejected at the local declaration site.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.NestedArray
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalOfArrayLocal
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs TOptional<TArray<int>> Opt
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional<TArray<int>> Opt;
	}
}
