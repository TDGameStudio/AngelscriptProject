/**
 * TWeakObjectPtr without a template argument is rejected. The template
 * callback requires exactly one subtype that is a UObject-derived class.
 *
 * @Theme Containers.TWeakObjectPtr
 * @Subject TWeakObjectPtr.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TWeakObjectPtr.TWeakObjectPtrMissingTypeArgs
 * @Kind CompileReject
 * @Covers TWeakObjectPtr.Declaration
 * @Inputs TWeakObjectPtr Weak
 * @Return does not compile
 * @Namespace TWeakObjectPtrTest
 */

namespace TWeakObjectPtrTest
{
	void Test()
	{
		TWeakObjectPtr Weak;
	}
}
