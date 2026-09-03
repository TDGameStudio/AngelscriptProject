/**
 * TMap with an unknown value type is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.UnknownType
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapUnknownType
 * @Kind CompileReject
 * @Covers TMap.Declaration
 * @Inputs TMap<int, NonExistent> Map
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<int, NonExistent> Map;
	}
}
