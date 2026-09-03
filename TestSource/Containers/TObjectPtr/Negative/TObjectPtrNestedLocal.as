/**
 * TObjectPtr<TObjectPtr<UObject>> is rejected: an object pointer is itself a
 * container, so nesting one inside another is rejected like any other
 * nested container.
 *
 * @Theme Containers.TObjectPtr
 * @Subject TObjectPtr.NestedObjectPtr
 * @Harness CompileReject
 * @Tag Containers.TObjectPtr.TObjectPtrNestedLocal
 * @Kind CompileReject
 * @Covers TObjectPtr.Declaration
 * @Inputs TObjectPtr<TObjectPtr<UObject>> Ptr
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TObjectPtrTest
 */

namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr<TObjectPtr<UObject>> Ptr;
	}
}
