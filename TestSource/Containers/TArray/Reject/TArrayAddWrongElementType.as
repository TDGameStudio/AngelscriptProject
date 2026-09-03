/**
 * Add of FString into TArray<int> is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.AddWrongElementType
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayAddWrongElementType
 * @Kind CompileReject
 * @Covers TArray.Add
 * @Inputs TArray<int> Arr; Arr.Add("hello")
 * @Return does not compile; "No matching signatures to 'TArray::Add"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<int> Arr;
		Arr.Add("hello");
	}
}
