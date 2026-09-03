/**
 * Three-level local nesting is still nested-container reject, not a new error.
 *
 * @Theme Containers.TArray
 * @Subject TArray.NestedLocalDeep
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayNestedLocalDeep
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs TArray<TArray<TArray<int>>> Matrix
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<TArray<TArray<int>>> Matrix;
	}
}
