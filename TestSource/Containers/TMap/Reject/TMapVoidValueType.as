/**
 * TMap with void value type is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.VoidValueType
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapVoidValueType
 * @Kind CompileReject
 * @Covers TMap.Declaration
 * @Inputs TMap<FString, void> Map
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<FString, void> Map;
	}
}
