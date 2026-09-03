/**
 * TSoftObjectPtr<TSoftObjectPtr<UObject>> is rejected: a soft pointer is
 * itself a container, so nesting one inside another is rejected like any
 * other nested container.
 *
 * @Theme Containers.TSoftObjectPtr
 * @Subject TSoftObjectPtr.NestedSoft
 * @Harness CompileReject
 * @Tag Containers.TSoftObjectPtr.TSoftObjectPtrNestedLocal
 * @Kind CompileReject
 * @Covers TSoftObjectPtr.Declaration
 * @Inputs TSoftObjectPtr<TSoftObjectPtr<UObject>> Soft
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSoftObjectPtrTest
 */

namespace TSoftObjectPtrTest
{
	void Test()
	{
		TSoftObjectPtr<TSoftObjectPtr<UObject>> Soft;
	}
}
