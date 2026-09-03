/**
 * Nested TMap<int, TMap<int, int>> as a UFUNCTION parameter is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedParam
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedParam
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UFUNCTION parameter TMap<int, TMap<int, int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	UFUNCTION()
	void TakeNestedMap(TMap<int, TMap<int, int>> Values)
	{
	}
}
