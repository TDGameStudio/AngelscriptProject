/**
 * TOptional<TMap<int, int>> is rejected: containers cannot be nested in
 * other containers. Rejected at the local declaration site.
 *
 * @Theme Containers.TOptional
 * @Subject TOptional.NestedMap
 * @Harness CompileReject
 * @Tag Containers.TOptional.TOptionalOfMapLocal
 * @Kind CompileReject
 * @Covers TOptional.Declaration
 * @Inputs TOptional<TMap<int, int>> Opt
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TOptionalTest
 */

namespace TOptionalTest
{
	void Test()
	{
		TOptional<TMap<int, int>> Opt;
	}
}
