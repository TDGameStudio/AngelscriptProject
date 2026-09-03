/**
 * Nested TMap of TMap of TMap as a local is rejected (same diagnostic as two layers).
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedLocalDeep
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedLocalDeep
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs TMap<int, TMap<int, TMap<int, int>>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int, TMap<int, TMap<int, int>>> Nested;
	}
}
