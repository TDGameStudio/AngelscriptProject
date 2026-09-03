/**
 * Assigning TArray<FString> onto TArray<int> is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.AssignWrongElementType
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayAssignWrongElementType
 * @Kind CompileReject
 * @Covers TArray.opAssign
 * @Inputs TArray<int> A; TArray<FString> B; A = B
 * @Return does not compile; no conversion / no matching opAssign between those TArray instantiations
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<int> A;
		TArray<FString> B;
		A = B;
	}
}
