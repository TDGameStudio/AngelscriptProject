/**
 * Nested TMap whose value is TArray as a local is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.OfArraysLocal
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapOfArraysLocal
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs TMap<int, TArray<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int, TArray<int>> Groups;
	}
}
