/**
 * TWeakObjectPtr<TWeakObjectPtr<UObject>> is rejected: a weak pointer is
 * itself a container, so nesting one inside another is rejected like any
 * other nested container.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.NestedWeak
 * @Harness CompileReject
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrNestedLocal
 * @Kind CompileReject
 * @Covers TWeakObjectPtr.Declaration
 * @Inputs TWeakObjectPtr<TWeakObjectPtr<UObject>> Weak
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TWeakObjectPtrTest
 */

namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<TWeakObjectPtr<UObject>> Weak;
	}
}
