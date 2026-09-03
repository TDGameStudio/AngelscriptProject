/**
 * Mutating a TSet passed by value is rejected (read-only copy).
 *
 * @Theme Containers.TSet
 * @Subject TSet.ByValueMutation
 * @Harness CompileReject
 * @Tag Containers.TSet.TSetByValueMutation
 * @Kind CompileReject
 * @Covers TSet.Add
 * @Inputs TSet by value; Set.Add
 * @Return does not compile; Non-const method call on read-only object reference
 * @Namespace TSetTest
 */

namespace TSetTest
{
	int MutateByValue(TSet<int> Values)
	{
		Values.Add(1);
		return Values.Num();
	}
}
