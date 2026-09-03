/**
 * TWeakObjectPtr of a primitive type is rejected. The template subtype must
 * be a UObject-derived class, so int is not accepted.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.PrimitiveSubType
 * @Harness CompileReject
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrOfPrimitive
 * @Kind CompileReject
 * @Covers TWeakObjectPtr.Declaration
 * @Inputs TWeakObjectPtr<int> Weak
 * @Return does not compile
 * @Namespace TWeakObjectPtrTest
 */

namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<int> Weak;
	}
}
