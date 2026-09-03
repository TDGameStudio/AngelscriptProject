/**
 * TMap with only one template parameter is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.OneTypeArg
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapOneTypeArg
 * @Kind CompileReject
 * @Covers TMap.Declaration
 * @Inputs TMap<int> Map
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int> Map;
	}
}
