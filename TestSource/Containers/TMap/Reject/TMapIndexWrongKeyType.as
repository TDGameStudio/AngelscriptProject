/**
 * Bracket access with a key of the wrong type is rejected.
 *
 * @Theme Containers.TMap
 * @Subject TMap.IndexWrongKeyType
 * @Harness CompileReject
 * @Tag Containers.TMap.TMapIndexWrongKeyType
 * @Kind CompileReject
 * @Covers TMap.opIndex
 * @Inputs TMap<FString, int>; Map[42]
 * @Return does not compile
 * @Namespace TMapTest
 */

namespace TMapTest
{
	void Test()
	{
		TMap<FString, int> Map;
		int X = Map[42];
	}
}
