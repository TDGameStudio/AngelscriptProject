/**
 * String index on TArray is rejected. Float index truncates and is Function, not Reject.
 *
 * @Theme Containers.TArray
 * @Subject TArray.StringIndexAccess
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayStringIndexAccess
 * @Kind CompileReject
 * @Covers TArray.opIndex
 * @Inputs TArray<int> Arr; Arr.Add(1); Arr["key"]
 * @Return does not compile; "No appropriate indexing operator found"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<int> Arr;
		Arr.Add(1);
		int X = Arr["key"];
	}
}
