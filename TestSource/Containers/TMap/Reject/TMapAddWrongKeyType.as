/**
 * Add with a key of the wrong type is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.AddWrongKeyType
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapAddWrongKeyType
 * @Kind CompileReject
 * @Covers TMap.Add
 * @Inputs TMap<FString, int>; Add(42, 1)
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		Map.Add(42, 1);
	}
}
