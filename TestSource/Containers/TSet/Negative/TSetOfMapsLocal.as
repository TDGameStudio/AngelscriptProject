/**
 * Nested TSet<TMap<int, int>> as a local is rejected.
 *
 * @Theme Containers.TSet
 * @Subject TSet.OfMapsLocal
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetOfMapsLocal
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs TSet<TMap<int, int>> Groups
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<TMap<int, int>> Groups;
	}
}
