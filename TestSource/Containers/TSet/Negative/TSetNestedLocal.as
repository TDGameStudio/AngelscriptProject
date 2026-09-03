/**
 * Nested TSet<TSet<int>> as a local is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedLocal
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedLocal
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs TSet<TSet<int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<TSet<int>> Nested;
	}
}
