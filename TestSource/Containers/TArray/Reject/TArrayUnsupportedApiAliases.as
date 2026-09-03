/**
 * UE aliases Find / FindLast / Reverse / RemoveAll are not bound.
 * Bound search is FindIndex; bound remove-by-value is Remove.
 * One program; the compiler reports a no-matching-signature diagnostic per call.
 *
 * @Theme Containers.TArray
 * @Subject TArray.UnsupportedApiAliases
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayUnsupportedApiAliases
 * @Kind CompileReject
 * @Covers TArray.Find
 * @Inputs TArray<int> with 1, 2; Find / FindLast / Reverse / RemoveAll
 * @Return does not compile; "No matching signatures to 'TArray::Find(const int)'"; FindLast / Reverse / RemoveAll the same form
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Find(1);
		Values.FindLast(1);
		Values.Reverse();
		Values.RemoveAll(1);
	}
}
