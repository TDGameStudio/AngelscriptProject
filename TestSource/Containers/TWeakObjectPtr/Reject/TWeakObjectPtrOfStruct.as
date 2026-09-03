/**
 * TWeakObjectPtr of a struct is rejected. The template subtype must be a
 * UObject-derived class, so a value type like FVector is not accepted.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.StructSubType
 * @Harness CompileReject
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrOfStruct
 * @Kind CompileReject
 * @Covers TWeakObjectPtr.Declaration
 * @Inputs TWeakObjectPtr<FVector> Weak
 * @Return does not compile
 * @Namespace TWeakObjectPtrTest
 */

namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr<FVector> Weak;
	}
}
