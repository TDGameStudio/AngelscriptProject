/**
 * TSoftObjectPtr without a template argument is rejected. The template
 * requires exactly one UObject-derived subtype.
 *
 * @Theme Containers.TSoftObjectPtr
 * @Subject TSoftObjectPtr.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TSoftObjectPtr.TSoftObjectPtrMissingTypeArgs
 * @Kind CompileReject
 * @Covers TSoftObjectPtr.Declaration
 * @Inputs TSoftObjectPtr Soft
 * @Return does not compile
 * @Namespace TSoftObjectPtrTest
 */

namespace TSoftObjectPtrTest
{
	void Test()
	{
		TSoftObjectPtr Soft;
	}
}
