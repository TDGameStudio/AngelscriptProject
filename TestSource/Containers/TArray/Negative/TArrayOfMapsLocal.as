/**
 * Nested TArray of TMap as a local is rejected.
 *
 * @Theme Containers.TArray
 * @Subject TArray.OfMapsLocal
 * @Harness CompileReject
 * @Tag Containers.TArray.TArrayOfMapsLocal
 * @Kind CompileReject
 * @Covers TArray.Nested
 * @Inputs TArray<TMap<int, FString>> Rows
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	void Test()
	{
		TArray<TMap<int, FString>> Rows;
	}
}
