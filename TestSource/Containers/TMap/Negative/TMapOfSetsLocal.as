/**
 * Nested TMap whose value is TSet as a local is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.OfSetsLocal
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapOfSetsLocal
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs TMap<int, TSet<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int, TSet<int>> Groups;
	}
}
