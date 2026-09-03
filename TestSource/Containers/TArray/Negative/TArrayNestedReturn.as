/**
 * Nested TArray<TArray<int>> as a UFUNCTION return type is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedReturn
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedReturn
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs UFUNCTION return TArray<TArray<int>>
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	UFUNCTION()
	TArray<TArray<int>> MakeNestedArray()
	{
		TArray<TArray<int>> Result;
		return Result;
	}
}
