/**
 * TArray of an undeclared element type is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.UnknownElementType
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayUnknownElementType
 * @Kind CompileReject
 * @Covers TArray.Construct
 * @Inputs TArray<NonExistent> Arr
 * @Return does not compile; "'NonExistent' is not declared"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<NonExistent> Arr;
	}
}
