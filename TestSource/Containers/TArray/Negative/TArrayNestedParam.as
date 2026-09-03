/**
 * Nested TArray<TArray<int>> as a UFUNCTION parameter is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedParam
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedParam
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UFUNCTION parameter TArray<TArray<int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	UFUNCTION()
	void TakeNestedArray(TArray<TArray<int>> Values)
	{
	}
}
