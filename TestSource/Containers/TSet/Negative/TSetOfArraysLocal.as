/**
 * Nested TSet<TArray<int>> as a local is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.OfArraysLocal
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetOfArraysLocal
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs TSet<TArray<int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<TArray<int>> Groups;
	}
}
