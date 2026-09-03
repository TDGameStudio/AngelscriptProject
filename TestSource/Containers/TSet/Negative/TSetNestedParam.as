/**
 * Nested TSet<TSet<int>> as a UFUNCTION parameter is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedParam
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedParam
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs UFUNCTION parameter TSet<TSet<int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	UFUNCTION()
	void TakeNestedSet(TSet<TSet<int>> Values)
	{
	}
}
