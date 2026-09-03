/**
 * Nested TMap<int, TMap<int, int>> as a UFUNCTION return is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.NestedReturn
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapNestedReturn
 * @Kind CompileReject
 * @Covers TMap.Nested
 * @Inputs UFUNCTION return TMap<int, TMap<int, int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TMapTest
 */

namespace TMapTest
{
	UFUNCTION()
	TMap<int, TMap<int, int>> MakeNestedMap()
	{
		TMap<int, TMap<int, int>> Values;
		return Values;
	}
}
