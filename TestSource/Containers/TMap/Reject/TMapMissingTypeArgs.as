/**
 * TMap without template parameters is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapMissingTypeArgs
 * @Kind CompileReject
 * @Covers TMap.Declaration
 * @Inputs TMap Map
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap Map;
	}
}
