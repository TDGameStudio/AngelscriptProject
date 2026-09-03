/**
 * Nested TSet<TSet<int>> as a UFUNCTION return is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedReturn
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedReturn
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UFUNCTION return TSet<TSet<int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	UFUNCTION()
	TSet<TSet<int>> MakeNestedSet()
	{
		TSet<TSet<int>> Values;
		return Values;
	}
}
