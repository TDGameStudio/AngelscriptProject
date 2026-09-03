/**
 * TArray<void> is not a valid instantiation.
 *
 * @Theme Containers.TArray
 * @Subject TArray.VoidType
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayVoidType
 * @Kind CompileReject
 * @Covers TArray.Construct
 * @Inputs TArray<void> Arr
 * @Return does not compile
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<void> Arr;
	}
}
