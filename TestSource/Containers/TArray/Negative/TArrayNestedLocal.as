/**
 * Nested TArray<TArray<int>> as a local is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedLocal
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedLocal
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs TArray<TArray<int>> Arr
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<TArray<int>> Arr;
	}
}
