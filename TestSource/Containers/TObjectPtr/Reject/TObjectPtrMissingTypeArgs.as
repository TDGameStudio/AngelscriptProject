/**
 * TObjectPtr without a template argument is rejected. The template callback
 * requires exactly one subtype that is a UObject-derived class.
 *
 * @Theme Containers.TObjectPtr
 * @Subject TObjectPtr.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TObjectPtr.TObjectPtrMissingTypeArgs
 * @Kind CompileReject
 * @Covers TObjectPtr.Declaration
 * @Inputs TObjectPtr Ptr
 * @Return does not compile
 * @Namespace TObjectPtrTest
 */

namespace TObjectPtrTest
{
	void Test()
	{
		TObjectPtr Ptr;
	}
}
