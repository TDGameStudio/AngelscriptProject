/**
 * TArray requires a subtype argument.
 *
 * @Theme Containers.TArray
 * @Subject TArray.MissingTypeArgs
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayMissingTypeArgs
 * @Kind CompileReject
 * @Covers TArray.Construct
 * @Inputs TArray Arr
 * @Return does not compile; "Template 'TArray' expects 1 sub type(s)"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray Arr;
	}
}
