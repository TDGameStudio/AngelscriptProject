/**
 * Nested TMap<int, TMap<int, int>> as a local is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedLocal
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedLocal
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs TMap<int, TMap<int, int>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int, TMap<int, int>> Nested;
	}
}
