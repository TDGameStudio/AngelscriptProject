/**
 * Nested TArray of TSet as a local is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.OfSetsLocal
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayOfSetsLocal
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs TArray<TSet<int>> Rows
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<TSet<int>> Rows;
	}
}
