/**
 * TObjectPtr of a struct is rejected. The template subtype must be a
 * UObject-derived class, so a value type like FVector is not accepted.
 *
 * @Theme Containers.TObjectPtr
 * @Subject TObjectPtr.StructSubType
 * @Harness CompileReject
 * @Tag Containers.TObjectPtr.TObjectPtrOfStruct
 * @Kind CompileReject
 * @Covers TObjectPtr.Declaration
 * @Inputs TObjectPtr<FVector> Ptr
 * @Return does not compile
 * @Namespace TObjectPtrTest
 */

namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr<FVector> Ptr;
	}
}
