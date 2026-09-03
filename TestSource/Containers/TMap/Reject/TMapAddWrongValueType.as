/**
 * Add with a value of the wrong type is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.AddWrongValueType
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapAddWrongValueType
 * @Kind CompileReject
 * @Covers TMap.Add
 * @Inputs TMap<FString, int>; Add("key", "value")
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		Map.Add("key", "value");
	}
}
