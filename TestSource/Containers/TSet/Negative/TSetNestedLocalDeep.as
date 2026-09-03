/**
 * Nested TSet of TSet of TSet as a local is rejected (same diagnostic as two layers).
 *
 * @Theme Containers.TSet
 * @Subject TSet.NestedLocalDeep
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetNestedLocalDeep
 * @Kind CompileReject
 * @Covers TSet.Nested
 * @Inputs TSet<TSet<TSet<int>>> Nested
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSetTest
 */

namespace TSetTest
{
	void Test()
	{
		TSet<TSet<TSet<int>>> Nested;
	}
}
