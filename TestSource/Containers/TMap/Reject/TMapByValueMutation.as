/**
 * Mutating a TMap passed by value is rejected (read-only copy).
 *
 * @Theme Containers.TMap
 * @Subject TMap.ByValueMutation
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapByValueMutation
 * @Kind CompileReject
 * @Covers TMap.Add
 * @Inputs TMap by value; Map.Add
 * @Return does not compile; Non-const method call on read-only object reference
 * @Namespace TMapTest
 */

namespace TMapTest
{
	int MutateByValue(TMap<int, FString> Map)
	{
		Map.Add(1, "One");
		return Map.Num();
	}
}
